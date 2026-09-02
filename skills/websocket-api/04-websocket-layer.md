# 04 — WebSocket Layer

The WebSocket layer lives in `server/internal/ws/`. It has four files with distinct responsibilities.

## Message Protocol (message.go)

All communication uses a JSON envelope:

```json
{"type": "message_type", "payload": {...}}
```

### Envelope

```go
type Envelope struct {
    Type    string          `json:"type"`
    Payload json.RawMessage `json:"payload"`
}
```

`Payload` is `json.RawMessage` (raw bytes) so the dispatcher can route by `Type` before deserializing the payload into a specific struct.

### Helper Functions

```go
func NewEnvelope(msgType string, payload interface{}) ([]byte, error)
func NewErrorEnvelope(msgType string, errMsg string) ([]byte, error)
```

`NewErrorEnvelope` appends `_error` to the type: `"move"` becomes `"move_error"`. The payload is always `{"error": "message"}`.

### Payload Types

Define request/response structs in this file. Current payloads:

```go
type CreateCharacterPayload struct {
    Name       string `json:"name"`
    AncestryID string `json:"ancestry_id"`
    ClassID    string `json:"class_id"`
    Str        int    `json:"str"`
    Dex        int    `json:"dex"`
    Con        int    `json:"con"`
    Int        int    `json:"int_"`
    Wis        int    `json:"wis"`
    Cha        int    `json:"cha"`
    ExceptStr  *int   `json:"exceptional_str,omitempty"`
    WorldSeed  int    `json:"world_seed"`
}

type MovePayload struct {
    CharacterID int    `json:"character_id"`
    Direction   string `json:"direction"`
}

type MoveResultPayload struct {
    Success     bool                    `json:"success"`
    NewCol      int                     `json:"new_col"`
    NewRow      int                     `json:"new_row"`
    TerrainID   string                  `json:"terrain_id"`
    TerrainName string                  `json:"terrain_name"`
    GameDay     int                     `json:"game_day"`
    GameHour    float64                 `json:"game_hour"`
    GotLost     bool                    `json:"got_lost"`
    NeedsRest   bool                    `json:"needs_rest"`
    Encounter   *EncounterResultPayload `json:"encounter,omitempty"`
}

type GetCharacterPayload struct {
    CharacterID int `json:"character_id"`
}

type QueryPayload struct {
    ID string `json:"id,omitempty"`
}
```

### Adding a New Message Type

1. Define the request payload struct (if it needs a payload)
2. Define the response payload struct (if the response differs from the model struct)
3. For simple reference data queries, the response IS the model struct — no separate payload needed

## Hub (hub.go)

The Hub manages all active WebSocket connections. One Hub per server.

```go
type Hub struct {
    clients    map[*Client]bool
    broadcast  chan []byte
    register   chan *Client
    unregister chan *Client
    mu         sync.RWMutex
}

func NewHub() *Hub
func (h *Hub) Register(client *Client)
func (h *Hub) Run()  // blocking — run as goroutine
```

### Run Loop

`Run()` is a blocking select loop that:
- **register** — adds client to `clients` map
- **unregister** — removes client, closes its send channel
- **broadcast** — sends a message to ALL connected clients (for future multiplayer events)

The `broadcast` channel drops messages for clients with full send buffers and cleans them up.

### Usage

```go
hub := ws.NewHub()
go hub.Run()  // must run as goroutine

// on new connection:
client := ws.NewClient(hub, conn, handler)
hub.Register(client)
```

## Client (client.go)

Each WebSocket connection gets a `Client` with two goroutines.

```go
type Client struct {
    hub     *Hub
    conn    *websocket.Conn
    send    chan []byte       // buffered channel (256)
    handler *Handler
}

func NewClient(hub *Hub, conn *websocket.Conn, handler *Handler) *Client
```

### ReadPump

Runs in a goroutine. Reads messages from the WebSocket, deserializes the Envelope, calls `handler.HandleMessage(env)`, and sends the response back to the client.

- Read timeout: 60 seconds
- On error or close: unregisters from hub, closes connection
- Invalid JSON: sends `parse_error` response and continues

### WritePump

Runs in a goroutine. Drains the `send` channel and writes each message to the WebSocket.

- Write timeout: 10 seconds
- Exits when send channel is closed (hub unregistered the client)

### Message Flow

```
Browser/Client → WebSocket → ReadPump → json.Unmarshal → handler.HandleMessage(env)
                                                              ↓
                                                         service.Query()
                                                              ↓
                                                         NewEnvelope()
                                                              ↓
Browser/Client ← WebSocket ← WritePump ← send channel ← response bytes
```

### Starting a Client

Both pumps must be started as goroutines after registering with the hub:

```go
client := ws.NewClient(hub, conn, handler)
hub.Register(client)
go client.WritePump()
go client.ReadPump()
```

Order matters: `WritePump` must start before `ReadPump` (ReadPump may immediately produce responses).
