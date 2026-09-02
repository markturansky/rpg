class_name TerrainData

enum TerrainType {
	DEEP_WATER,
	SHALLOW_WATER,
	BEACH,
	PLAINS,
	GRASSLAND,
	FOREST,
	DENSE_FOREST,
	HILLS,
	MOUNTAIN,
	DESERT,
	MARSH,
	TUNDRA,
	ROAD,
}

const TERRAIN_COLORS := {
	TerrainType.DEEP_WATER: Color(0.12, 0.22, 0.55),
	TerrainType.SHALLOW_WATER: Color(0.25, 0.45, 0.72),
	TerrainType.BEACH: Color(0.85, 0.78, 0.55),
	TerrainType.PLAINS: Color(0.72, 0.78, 0.42),
	TerrainType.GRASSLAND: Color(0.55, 0.70, 0.35),
	TerrainType.FOREST: Color(0.22, 0.50, 0.20),
	TerrainType.DENSE_FOREST: Color(0.12, 0.35, 0.12),
	TerrainType.HILLS: Color(0.60, 0.52, 0.35),
	TerrainType.MOUNTAIN: Color(0.50, 0.45, 0.40),
	TerrainType.DESERT: Color(0.88, 0.80, 0.50),
	TerrainType.MARSH: Color(0.35, 0.48, 0.32),
	TerrainType.TUNDRA: Color(0.78, 0.82, 0.85),
	TerrainType.ROAD: Color(0.55, 0.48, 0.35),
}

const TERRAIN_NAMES := {
	TerrainType.DEEP_WATER: "Deep Water",
	TerrainType.SHALLOW_WATER: "Shallow Water",
	TerrainType.BEACH: "Beach",
	TerrainType.PLAINS: "Plains",
	TerrainType.GRASSLAND: "Grassland",
	TerrainType.FOREST: "Forest",
	TerrainType.DENSE_FOREST: "Dense Forest",
	TerrainType.HILLS: "Hills",
	TerrainType.MOUNTAIN: "Mountain",
	TerrainType.DESERT: "Desert",
	TerrainType.MARSH: "Marsh",
	TerrainType.TUNDRA: "Tundra",
	TerrainType.ROAD: "Road",
}

static func terrain_from_elevation(elevation: float, moisture: float) -> TerrainType:
	if elevation < -0.3:
		return TerrainType.DEEP_WATER
	elif elevation < -0.1:
		return TerrainType.SHALLOW_WATER
	elif elevation < 0.0:
		return TerrainType.BEACH
	elif elevation > 0.7:
		return TerrainType.MOUNTAIN
	elif elevation > 0.5:
		return TerrainType.HILLS
	elif elevation > 0.3:
		if moisture < 0.3:
			return TerrainType.DESERT
		elif moisture > 0.7:
			return TerrainType.DENSE_FOREST
		else:
			return TerrainType.FOREST
	else:
		if moisture < 0.2:
			return TerrainType.DESERT
		elif moisture < 0.4:
			return TerrainType.PLAINS
		elif moisture > 0.8:
			return TerrainType.MARSH
		elif moisture > 0.6:
			return TerrainType.FOREST
		else:
			return TerrainType.GRASSLAND
