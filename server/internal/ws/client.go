package ws

import (
	"context"
	"encoding/json"
	"log"
	"time"

	"nhooyr.io/websocket"
)

type Client struct {
	hub     *Hub
	conn    *websocket.Conn
	send    chan []byte
	handler *Handler
}

func NewClient(hub *Hub, conn *websocket.Conn, handler *Handler) *Client {
	return &Client{
		hub:     hub,
		conn:    conn,
		send:    make(chan []byte, 256),
		handler: handler,
	}
}

func (c *Client) ReadPump() {
	defer func() {
		c.hub.unregister <- c
		c.conn.Close(websocket.StatusNormalClosure, "")
	}()

	for {
		ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
		_, message, err := c.conn.Read(ctx)
		cancel()
		if err != nil {
			if websocket.CloseStatus(err) == websocket.StatusNormalClosure ||
				websocket.CloseStatus(err) == websocket.StatusGoingAway {
				log.Printf("[CLIENT] connection closed normally")
			} else {
				log.Printf("[CLIENT] read error: %v", err)
			}
			return
		}

		var env Envelope
		if err := json.Unmarshal(message, &env); err != nil {
			log.Printf("[CLIENT] invalid message format: %v", err)
			resp, _ := NewErrorEnvelope("parse", "invalid message format")
			c.sendMessage(resp)
			continue
		}

		response := c.handler.HandleMessage(env)
		if response != nil {
			c.sendMessage(response)
		}
	}
}

func (c *Client) WritePump() {
	defer c.conn.Close(websocket.StatusNormalClosure, "")

	for message := range c.send {
		ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		err := c.conn.Write(ctx, websocket.MessageText, message)
		cancel()
		if err != nil {
			log.Printf("[CLIENT] write error: %v", err)
			return
		}
	}
}

func (c *Client) sendMessage(msg []byte) {
	select {
	case c.send <- msg:
	default:
		log.Printf("[CLIENT] send buffer full, dropping message")
	}
}
