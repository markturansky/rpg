extends CanvasLayer

func update_terrain_info(hex_coord: Vector2i, terrain_name: String):
	$TerrainLabel.text = "%s  (%d, %d)" % [terrain_name, hex_coord.x, hex_coord.y]
