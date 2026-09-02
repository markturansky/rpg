# 06 — Server Setup & Entry Point

## main.go (server/cmd/rpg-server/main.go)

The entry point wires everything together: database, services, WebSocket hub, HTTP server, and graceful shutdown.

### Flags

```go
addr := flag.String("addr", ":8080", "server listen address")
dbPath := flag.String("db", "rpg.db", "sqlite database path")
```

### Wiring Order

```go
// 1. Open database (runs schema + migrations automatically)
db, err := database.NewDB(*dbPath)
defer db.Close()

// 2. Get raw *sql.DB for services
sqlDB := db.DB

// 3. Create all 16 services
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
exploredHexService := models.NewExploredHexService(sqlDB)

// 4. Create handler with all services
handler := ws.NewHandler(
    ancestryService, classService, weaponService, armorService,
    shieldService, terrainService, monsterService, spellService,
    itemService, abilityModService, encounterService, characterService,
    questService, strongholdService, combatLogService, exploredHexService,
)

// 5. Create and start hub
hub := ws.NewHub()
go hub.Run()
```

### HTTP Endpoints

Only two routes:

```go
mux := http.NewServeMux()

// WebSocket upgrade endpoint
mux.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
    conn, err := websocket.Accept(w, r, &websocket.AcceptOptions{
        InsecureSkipVerify: true,  // allows any origin (dev mode)
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

// Health check
mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
    w.WriteHeader(http.StatusOK)
    w.Write([]byte("ok"))
})
```

### HTTP Server Configuration

```go
server := &http.Server{
    Addr:         *addr,
    Handler:      mux,
    ReadTimeout:  15 * time.Second,
    WriteTimeout: 15 * time.Second,
    IdleTimeout:  120 * time.Second,
}
```

### Graceful Shutdown

Listens for `SIGINT` or `SIGTERM`, then shuts down with a 10-second timeout:

```go
shutdown := make(chan os.Signal, 1)
signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)

go func() {
    server.ListenAndServe()
}()

<-shutdown
ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
defer cancel()
server.Shutdown(ctx)
```

## Running the Server

```bash
# from server/ directory
go run ./cmd/rpg-server/

# with flags
go run ./cmd/rpg-server/ -addr :9876 -db my_game.db

# build binary
go build -o rpg-server ./cmd/rpg-server/
./rpg-server -addr :8080 -db rpg.db
```

## Connecting a Client

### Browser (JavaScript)

```javascript
const ws = new WebSocket("ws://localhost:8080/ws");

ws.onopen = () => {
    ws.send(JSON.stringify({type: "get_ancestries"}));
};

ws.onmessage = (event) => {
    const env = JSON.parse(event.data);
    console.log(env.type, env.payload);
};
```

### Python

```python
import websocket, json

ws = websocket.create_connection("ws://localhost:8080/ws")
ws.send(json.dumps({"type": "get_ancestries"}))
result = json.loads(ws.recv())
print(result["type"], result["payload"])
ws.close()
```

### Go

```go
ctx := context.Background()
conn, _, err := websocket.Dial(ctx, "ws://localhost:8080/ws", nil)
// send/recv with conn.Write/conn.Read
```

### Any Native Binary (C, Rust, Godot, SDL2)

WebSocket is just HTTP upgrade — any language with a WebSocket client library works. The protocol is plain JSON text frames.

## Adding a New Service to main.go

1. Import is already `"rpg/internal/models"` — no new import needed
2. Add `thingService := models.NewThingService(sqlDB)` after the other service constructors
3. Add `thingService` as a new argument to `ws.NewHandler(...)`
4. Update the `Handler` struct and `NewHandler()` in `handlers.go` to accept it
5. Run `go build ./...` to verify

## Log Format

All log lines use bracketed prefixes for filtering:

- `[STARTUP]` — server initialization
- `[MIGRATION]` — schema migration application
- `[SHUTDOWN]` — graceful shutdown
- `[HTTP]` — HTTP-level events
- `[HUB]` — client connect/disconnect
- `[CLIENT]` — per-connection read/write events
- `[WS]` — message dispatch
- `[CHARACTER]` — character creation
- `[MOVE]` — movement results
