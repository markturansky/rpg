package ws

import (
	"encoding/json"
	"fmt"
	"log"
	"math/rand"

	"rpg/internal/models"
)

type Handler struct {
	ancestryService     *models.AncestryService
	classService        *models.ClassService
	weaponService       *models.WeaponService
	armorService        *models.ArmorService
	shieldService       *models.ShieldService
	terrainService      *models.TerrainService
	monsterService      *models.MonsterService
	spellService        *models.SpellService
	itemService         *models.ItemService
	abilityModService   *models.AbilityModService
	encounterService    *models.EncounterService
	characterService    *models.CharacterService
	questService        *models.QuestService
	strongholdService   *models.StrongholdService
	combatLogService    *models.CombatLogService
	exploredTileService *models.ExploredTileService
	tileService         *models.TileService
}

func NewHandler(
	ancestryService *models.AncestryService,
	classService *models.ClassService,
	weaponService *models.WeaponService,
	armorService *models.ArmorService,
	shieldService *models.ShieldService,
	terrainService *models.TerrainService,
	monsterService *models.MonsterService,
	spellService *models.SpellService,
	itemService *models.ItemService,
	abilityModService *models.AbilityModService,
	encounterService *models.EncounterService,
	characterService *models.CharacterService,
	questService *models.QuestService,
	strongholdService *models.StrongholdService,
	combatLogService *models.CombatLogService,
	exploredTileService *models.ExploredTileService,
	tileService *models.TileService,
) *Handler {
	return &Handler{
		ancestryService:     ancestryService,
		classService:        classService,
		weaponService:       weaponService,
		armorService:        armorService,
		shieldService:       shieldService,
		terrainService:      terrainService,
		monsterService:      monsterService,
		spellService:        spellService,
		itemService:         itemService,
		abilityModService:   abilityModService,
		encounterService:    encounterService,
		characterService:    characterService,
		questService:        questService,
		strongholdService:   strongholdService,
		combatLogService:    combatLogService,
		exploredTileService: exploredTileService,
		tileService:         tileService,
	}
}

func (h *Handler) HandleMessage(env Envelope) []byte {
	log.Printf("[WS] received: %s", env.Type)

	switch env.Type {
	case "get_ancestries":
		return h.handleGetAncestries()
	case "get_classes":
		return h.handleGetClasses()
	case "get_weapons":
		return h.handleGetWeapons()
	case "get_armor":
		return h.handleGetArmor()
	case "get_shields":
		return h.handleGetShields()
	case "get_terrain":
		return h.handleGetTerrain()
	case "get_monsters":
		return h.handleGetMonsters()
	case "get_spells":
		return h.handleGetSpells()
	case "get_items":
		return h.handleGetItems()
	case "get_ability_mod":
		return h.handleGetAbilityMod(env.Payload)
	case "get_encounters":
		return h.handleGetEncounters(env.Payload)
	case "create_character":
		return h.handleCreateCharacter(env.Payload)
	case "get_character":
		return h.handleGetCharacter(env.Payload)
	case "move":
		return h.handleMove(env.Payload)
	case "zoom_in":
		return h.handleZoomIn(env.Payload)
	case "zoom_out":
		return h.handleZoomOut(env.Payload)
	case "get_starting_equipment":
		return h.handleGetStartingEquipment(env.Payload)
	default:
		resp, _ := NewErrorEnvelope("unknown", "unknown message type: "+env.Type)
		return resp
	}
}

func (h *Handler) handleGetAncestries() []byte {
	ancestries, err := h.ancestryService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("ancestries", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("ancestries", ancestries)
	return resp
}

func (h *Handler) handleGetClasses() []byte {
	classes, err := h.classService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("classes", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("classes", classes)
	return resp
}

func (h *Handler) handleGetWeapons() []byte {
	weapons, err := h.weaponService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("weapons", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("weapons", weapons)
	return resp
}

func (h *Handler) handleGetArmor() []byte {
	armor, err := h.armorService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("armor", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("armor", armor)
	return resp
}

func (h *Handler) handleGetShields() []byte {
	shields, err := h.shieldService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("shields", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("shields", shields)
	return resp
}

func (h *Handler) handleGetTerrain() []byte {
	terrain, err := h.terrainService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("terrain", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("terrain", terrain)
	return resp
}

func (h *Handler) handleGetMonsters() []byte {
	monsters, err := h.monsterService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("monsters", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("monsters", monsters)
	return resp
}

func (h *Handler) handleGetSpells() []byte {
	spells, err := h.spellService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("spells", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("spells", spells)
	return resp
}

func (h *Handler) handleGetItems() []byte {
	items, err := h.itemService.GetAll()
	if err != nil {
		resp, _ := NewErrorEnvelope("items", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("items", items)
	return resp
}

func (h *Handler) handleGetAbilityMod(payload json.RawMessage) []byte {
	var req struct {
		Ability string `json:"ability"`
		Score   int    `json:"score"`
	}
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("ability_mod", "invalid payload")
		return resp
	}
	mod, err := h.abilityModService.GetModsForScore(req.Ability, req.Score)
	if err != nil {
		resp, _ := NewErrorEnvelope("ability_mod", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("ability_mod", mod)
	return resp
}

func (h *Handler) handleGetEncounters(payload json.RawMessage) []byte {
	var req QueryPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("encounters", "invalid payload")
		return resp
	}
	entries, err := h.encounterService.GetByTerrain(req.ID)
	if err != nil {
		resp, _ := NewErrorEnvelope("encounters", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("encounters", entries)
	return resp
}

func (h *Handler) handleCreateCharacter(payload json.RawMessage) []byte {
	var req CreateCharacterPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("character_created", "invalid payload")
		return resp
	}

	if req.Name == "" || req.AncestryID == "" || req.ClassID == "" {
		resp, _ := NewErrorEnvelope("character_created", "name, ancestry_id, and class_id are required")
		return resp
	}

	meets, err := h.classService.MeetsMinimumScores(req.ClassID, map[string]int{
		"str": req.Str, "dex": req.Dex, "con": req.Con,
		"int": req.Int, "wis": req.Wis, "cha": req.Cha,
	})
	if err != nil {
		resp, _ := NewErrorEnvelope("character_created", err.Error())
		return resp
	}
	if !meets {
		resp, _ := NewErrorEnvelope("character_created", "ability scores do not meet minimums for class")
		return resp
	}

	ancestry, err := h.ancestryService.GetByID(req.AncestryID)
	if err != nil {
		resp, _ := NewErrorEnvelope("character_created", "invalid ancestry_id")
		return resp
	}

	cls, err := h.classService.GetByID(req.ClassID)
	if err != nil {
		resp, _ := NewErrorEnvelope("character_created", "invalid class_id")
		return resp
	}

	finalStr := req.Str + ancestry.StrAdj
	finalDex := req.Dex + ancestry.DexAdj
	finalCon := req.Con + ancestry.ConAdj
	finalInt := req.Int + ancestry.IntAdj
	finalWis := req.Wis + ancestry.WisAdj
	finalCha := req.Cha + ancestry.ChaAdj

	hp := rollDice(1, cls.HitDie)
	conMod, _ := h.abilityModService.GetModsForScore("con", finalCon)
	if conMod != nil {
		hp += conMod.HPMod
	}
	if hp < 1 {
		hp = 1
	}

	gold := rollDice(cls.GoldDice, cls.GoldDie) * cls.GoldMultiplier

	startingTile := models.TileAddress(models.RootAddress, 55)

	character := &models.Character{
		Name:           req.Name,
		AncestryID:     req.AncestryID,
		ClassID:        req.ClassID,
		Level:          1,
		XP:             0,
		HP:             hp,
		MaxHP:          hp,
		AC:             10,
		Gold:           gold,
		Str:            finalStr,
		Dex:            finalDex,
		Con:            finalCon,
		Int:            finalInt,
		Wis:            finalWis,
		Cha:            finalCha,
		ExceptionalStr: req.ExceptStr,
		MovementRate:   ancestry.MovementRate,
		CurrentTile:    startingTile,
		GameDay:        1,
		GameHour:       8.0,
		Rations:        7,
		WorldSeed:      req.WorldSeed,
	}

	created, err := h.characterService.Create(character)
	if err != nil {
		resp, _ := NewErrorEnvelope("character_created", err.Error())
		return resp
	}

	_, _ = h.tileService.GetOrCreate(startingTile, req.WorldSeed)

	terrainID := models.TerrainForAddress(startingTile, req.WorldSeed)
	_ = h.exploredTileService.MarkExplored(created.ID, startingTile, &terrainID)

	log.Printf("[CHARACTER] created id=%d name=%s class=%s ancestry=%s", created.ID, created.Name, req.ClassID, req.AncestryID)
	resp, _ := NewEnvelope("character_created", created)
	return resp
}

func (h *Handler) handleGetCharacter(payload json.RawMessage) []byte {
	var req GetCharacterPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("character", "invalid payload")
		return resp
	}
	character, err := h.characterService.GetByID(req.CharacterID)
	if err != nil {
		resp, _ := NewErrorEnvelope("character", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("character", character)
	return resp
}

func (h *Handler) handleMove(payload json.RawMessage) []byte {
	var req MovePayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("move_result", "invalid payload")
		return resp
	}

	dir := models.Direction(req.Direction)
	if !models.ValidDirections[dir] {
		resp, _ := NewErrorEnvelope("move_result", "invalid direction (must be n, s, e, or w)")
		return resp
	}

	character, err := h.characterService.GetByID(req.CharacterID)
	if err != nil {
		resp, _ := NewErrorEnvelope("move_result", "character not found")
		return resp
	}

	currentTile := character.CurrentTile
	newTile := models.Neighbor(currentTile, dir)

	if newTile == currentTile {
		resp, _ := NewErrorEnvelope("move_result", "cannot move beyond world boundary")
		return resp
	}

	terrainID := models.TerrainForAddress(newTile, character.WorldSeed)

	terrain, err := h.terrainService.GetByID(terrainID)
	if err != nil {
		log.Printf("[MOVE ERROR] terrainService.GetByID(%q) failed: %v", terrainID, err)
		resp, _ := NewErrorEnvelope("move_result", fmt.Sprintf("failed to resolve terrain %q: %v", terrainID, err))
		return resp
	}

	if terrain.MoveCost >= 999.0 {
		resp, _ := NewErrorEnvelope("move_result", "cannot move to impassable terrain")
		return resp
	}

	hoursNeeded := terrain.MoveCost * (120.0 / float64(character.MovementRate))
	character.GameHour += hoursNeeded
	character.TravelHoursDay += hoursNeeded
	needsRest := character.TravelHoursDay >= 8.0

	if character.GameHour >= 24.0 {
		character.GameHour -= 24.0
		character.GameDay++
		character.TravelHoursDay = 0
	}

	gotLost := false
	if terrain.LostChance > 0 {
		roll := rand.Intn(6) + 1
		gotLost = roll <= terrain.LostChance
	}

	if !gotLost {
		character.CurrentTile = newTile
	}

	if err := h.characterService.Update(character); err != nil {
		resp, _ := NewErrorEnvelope("move_result", "failed to save character")
		return resp
	}

	_, _ = h.tileService.GetOrCreate(character.CurrentTile, character.WorldSeed)
	_ = h.exploredTileService.MarkExplored(character.ID, character.CurrentTile, &terrainID)

	actualTerrain := models.TerrainForAddress(character.CurrentTile, character.WorldSeed)
	actualTerrainObj, _ := h.terrainService.GetByID(actualTerrain)
	terrainName := actualTerrain
	if actualTerrainObj != nil {
		terrainName = actualTerrainObj.Name
	}

	result := MoveResultPayload{
		Success:     true,
		NewTile:     character.CurrentTile,
		TerrainID:   actualTerrain,
		TerrainName: terrainName,
		TierName:    models.TierName(character.CurrentTile),
		Depth:       models.Depth(character.CurrentTile),
		GameDay:     character.GameDay,
		GameHour:    character.GameHour,
		GotLost:     gotLost,
		NeedsRest:   needsRest,
	}

	log.Printf("[MOVE] character %d -> %s (%s) lost=%v", character.ID, character.CurrentTile, terrainName, gotLost)
	resp, _ := NewEnvelope("move_result", result)
	return resp
}

func (h *Handler) handleZoomIn(payload json.RawMessage) []byte {
	var req ZoomPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "invalid payload")
		return resp
	}

	character, err := h.characterService.GetByID(req.CharacterID)
	if err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "character not found")
		return resp
	}

	currentDepth := models.Depth(character.CurrentTile)
	if currentDepth >= models.MaxDepth {
		resp, _ := NewErrorEnvelope("zoom_result", "already at maximum zoom depth")
		return resp
	}

	if req.ChildIndex < 0 || req.ChildIndex >= models.ChildrenPerTile {
		resp, _ := NewErrorEnvelope("zoom_result", fmt.Sprintf("invalid child_index (must be 0-%d)", models.ChildrenPerTile-1))
		return resp
	}

	newTile := models.Child(character.CurrentTile, req.ChildIndex)
	character.CurrentTile = newTile

	if err := h.characterService.Update(character); err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "failed to save character")
		return resp
	}

	tile, err := h.tileService.GetOrCreate(newTile, character.WorldSeed)
	if err != nil {
		log.Printf("[ZOOM_IN ERROR] GetOrCreate(%s, %d) failed: %v", newTile, character.WorldSeed, err)
		terrainID := models.TerrainForAddress(newTile, character.WorldSeed)
		log.Printf("[ZOOM_IN ERROR] TerrainForAddress returned: %q", terrainID)
		resp, _ := NewErrorEnvelope("zoom_result", fmt.Sprintf("failed to materialize tile %s: %v (terrain_id=%s)", newTile, err, terrainID))
		return resp
	}

	_ = h.exploredTileService.MarkExplored(character.ID, newTile, &tile.TerrainID)

	siblings, err := h.tileService.MaterializeChildren(models.Parent(newTile), character.WorldSeed)
	if err != nil {
		log.Printf("[ZOOM_IN ERROR] MaterializeChildren(%s) failed: %v", models.Parent(newTile), err)
	}
	var siblingBriefs []TileBrief
	for _, s := range siblings {
		siblingBriefs = append(siblingBriefs, TileBrief{
			Address:   s.Address,
			TerrainID: s.TerrainID,
		})
	}

	result := ZoomResultPayload{
		Success:    true,
		NewAddress: newTile,
		TierName:   models.TierName(newTile),
		Depth:      models.Depth(newTile),
		TerrainID:  tile.TerrainID,
		Siblings:   siblingBriefs,
	}

	log.Printf("[ZOOM_IN] character %d -> %s (depth %d)", character.ID, newTile, result.Depth)
	resp, _ := NewEnvelope("zoom_result", result)
	return resp
}

func (h *Handler) handleZoomOut(payload json.RawMessage) []byte {
	var req ZoomPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "invalid payload")
		return resp
	}

	character, err := h.characterService.GetByID(req.CharacterID)
	if err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "character not found")
		return resp
	}

	currentDepth := models.Depth(character.CurrentTile)
	if currentDepth <= 0 {
		resp, _ := NewErrorEnvelope("zoom_result", "already at world tier, cannot zoom out further")
		return resp
	}

	newTile := models.Parent(character.CurrentTile)
	if newTile == "" {
		resp, _ := NewErrorEnvelope("zoom_result", "already at root tile")
		return resp
	}
	character.CurrentTile = newTile

	if err := h.characterService.Update(character); err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "failed to save character")
		return resp
	}

	tile, err := h.tileService.GetOrCreate(newTile, character.WorldSeed)
	if err != nil {
		resp, _ := NewErrorEnvelope("zoom_result", "failed to resolve tile")
		return resp
	}

	var siblingBriefs []TileBrief
	parentOfNew := models.Parent(newTile)
	if parentOfNew != "" {
		siblings, _ := h.tileService.MaterializeChildren(parentOfNew, character.WorldSeed)
		for _, s := range siblings {
			siblingBriefs = append(siblingBriefs, TileBrief{
				Address:   s.Address,
				TerrainID: s.TerrainID,
			})
		}
	}

	result := ZoomResultPayload{
		Success:    true,
		NewAddress: newTile,
		TierName:   models.TierName(newTile),
		Depth:      models.Depth(newTile),
		TerrainID:  tile.TerrainID,
		Siblings:   siblingBriefs,
	}

	log.Printf("[ZOOM_OUT] character %d -> %s (depth %d)", character.ID, newTile, result.Depth)
	resp, _ := NewEnvelope("zoom_result", result)
	return resp
}

func (h *Handler) handleGetStartingEquipment(payload json.RawMessage) []byte {
	var req QueryPayload
	if err := json.Unmarshal(payload, &req); err != nil {
		resp, _ := NewErrorEnvelope("starting_equipment", "invalid payload")
		return resp
	}
	entries, err := h.itemService.GetStartingEquipment(req.ID)
	if err != nil {
		resp, _ := NewErrorEnvelope("starting_equipment", err.Error())
		return resp
	}
	resp, _ := NewEnvelope("starting_equipment", entries)
	return resp
}

func rollDice(count, die int) int {
	total := 0
	for i := 0; i < count; i++ {
		total += rand.Intn(die) + 1
	}
	return total
}
