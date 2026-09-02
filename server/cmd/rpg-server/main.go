package main

import (
	"context"
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"nhooyr.io/websocket"

	"rpg/internal/database"
	"rpg/internal/models"
	"rpg/internal/render"
	"rpg/internal/ws"
)

func main() {
	addr := flag.String("addr", ":8080", "server listen address")
	dbPath := flag.String("db", "rpg.db", "sqlite database path")
	flag.Parse()

	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
	log.Printf("[STARTUP] opening database %s", *dbPath)

	db, err := database.NewDB(*dbPath)
	if err != nil {
		log.Fatalf("failed to initialize database: %v", err)
	}
	defer db.Close()

	sqlDB := db.DB

	ancestryService := models.NewAncestryService(sqlDB)
	classService := models.NewClassService(sqlDB)
	weaponService := models.NewWeaponService(sqlDB)
	armorService := models.NewArmorService(sqlDB)
	shieldService := models.NewShieldService(sqlDB)
	terrainService := models.NewTerrainService(sqlDB)
	monsterService := models.NewMonsterService(sqlDB)
	spellService := models.NewSpellService(sqlDB)
	itemService := models.NewItemService(sqlDB)
	abilityModService := models.NewAbilityModService(sqlDB)
	encounterService := models.NewEncounterService(sqlDB)
	characterService := models.NewCharacterService(sqlDB)
	questService := models.NewQuestService(sqlDB)
	strongholdService := models.NewStrongholdService(sqlDB)
	combatLogService := models.NewCombatLogService(sqlDB)
	exploredTileService := models.NewExploredTileService(sqlDB)
	tileService := models.NewTileService(sqlDB)

	handler := ws.NewHandler(
		ancestryService,
		classService,
		weaponService,
		armorService,
		shieldService,
		terrainService,
		monsterService,
		spellService,
		itemService,
		abilityModService,
		encounterService,
		characterService,
		questService,
		strongholdService,
		combatLogService,
		exploredTileService,
		tileService,
	)

	execPath, err := os.Executable()
	if err != nil {
		log.Fatalf("[STARTUP] failed to determine executable path: %v", err)
	}
	spritesDir := filepath.Join(filepath.Dir(execPath), "..", "sprites")
	if _, err := os.Stat(filepath.Join(spritesDir, "sprites.json")); err != nil {
		spritesDir = filepath.Join("..", "sprites")
	}

	atlas, err := render.NewSpriteAtlas(spritesDir)
	if err != nil {
		log.Printf("[STARTUP] sprite atlas not loaded (tile rendering disabled): %v", err)
	}

	var tileRenderer *render.TileRenderer
	if atlas != nil {
		tileRenderer = render.NewTileRenderer(atlas, 42, 256)
		log.Println("[STARTUP] tile renderer initialized")
	}

	hub := ws.NewHub()
	go hub.Run()

	mux := http.NewServeMux()

	mux.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{
			InsecureSkipVerify: true,
		})
		if err != nil {
			log.Printf("[HTTP] websocket accept error: %v", err)
			return
		}

		client := ws.NewClient(hub, conn, handler)
		hub.Register(client)
		go client.WritePump()
		go client.ReadPump()
	})

	if tileRenderer != nil {
		mux.HandleFunc("GET /tiles/{address...}", render.NewTileHandler(tileRenderer))
		log.Println("[STARTUP] tile endpoint registered at GET /tiles/{address}")
	}

	mux.HandleFunc("GET /map", render.NewMapHandler())
	log.Println("[STARTUP] map endpoint registered at GET /map")

	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("ok"))
	})

	server := &http.Server{
		Addr:         *addr,
		Handler:      mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  120 * time.Second,
	}

	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

	go func() {
		log.Printf("[STARTUP] listening on %s", *addr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("server error: %v", err)
		}
	}()

	<-shutdown
	log.Println("[SHUTDOWN] shutting down gracefully...")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := server.Shutdown(ctx); err != nil {
		log.Fatalf("forced shutdown: %v", err)
	}

	log.Println("[SHUTDOWN] complete")
}
