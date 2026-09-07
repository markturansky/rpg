package main

import (
	"flag"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"worldbuilder/internal/api"
	"worldbuilder/internal/database"
)

func main() {
	addr := flag.String("addr", ":8080", "HTTP listen address")
	dbPath := flag.String("db", "world-builder.db", "SQLite database path")
	flag.Parse()

	db, err := database.New(*dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	server := &http.Server{Addr: *addr, Handler: api.NewHandler(db), ReadTimeout: 15 * time.Second, WriteTimeout: 15 * time.Second, IdleTimeout: 120 * time.Second}
	go func() {
		log.Printf("world-builder API listening on %s", *addr)
		if err := server.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatal(err)
		}
	}()
	shutdown := make(chan os.Signal, 1)
	signal.Notify(shutdown, os.Interrupt, syscall.SIGTERM)
	<-shutdown
	server.Close()
}
