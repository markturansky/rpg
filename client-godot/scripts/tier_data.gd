class_name TierData

enum Tier {
	WORLD,
	REGIONAL,
	LOCAL,
	DISTRICT,
	STREET,
	TACTICAL,
}

const TIER_NAMES := {
	Tier.WORLD: "World",
	Tier.REGIONAL: "Regional",
	Tier.LOCAL: "Local",
	Tier.DISTRICT: "District",
	Tier.STREET: "Street",
	Tier.TACTICAL: "Tactical",
}

const TIER_SCALE_LABEL := {
	Tier.WORLD: "6 miles/hex",
	Tier.REGIONAL: "1 mile/hex",
	Tier.LOCAL: "880 ft/hex",
	Tier.DISTRICT: "147 ft/hex",
	Tier.STREET: "24 ft/hex",
	Tier.TACTICAL: "4 ft/hex",
}

const CHILDREN_PER_HEX := 6

const TIER_SCENE_PATHS := {
	Tier.WORLD: "res://scenes/world_tier.tscn",
	Tier.REGIONAL: "res://scenes/regional_tier.tscn",
	Tier.LOCAL: "res://scenes/local_tier.tscn",
	Tier.DISTRICT: "res://scenes/district_tier.tscn",
	Tier.STREET: "res://scenes/street_tier.tscn",
	Tier.TACTICAL: "res://scenes/tactical_tier.tscn",
}

static func child_tier(tier: Tier) -> Tier:
	match tier:
		Tier.WORLD: return Tier.REGIONAL
		Tier.REGIONAL: return Tier.LOCAL
		Tier.LOCAL: return Tier.DISTRICT
		Tier.DISTRICT: return Tier.STREET
		Tier.STREET: return Tier.TACTICAL
		_: return tier

static func parent_tier(tier: Tier) -> Tier:
	match tier:
		Tier.REGIONAL: return Tier.WORLD
		Tier.LOCAL: return Tier.REGIONAL
		Tier.DISTRICT: return Tier.LOCAL
		Tier.STREET: return Tier.DISTRICT
		Tier.TACTICAL: return Tier.STREET
		_: return tier

static func has_children(tier: Tier) -> bool:
	return tier != Tier.TACTICAL

static func has_parent(tier: Tier) -> bool:
	return tier != Tier.WORLD
