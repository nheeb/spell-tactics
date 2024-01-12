extends Node3D


func _on_movement_range_button_pressed() -> void:
	var movement_tiles = $TileGrid.get_all_tiles_in_distance(3, 3, 2)
	$TileGrid._highlight_tile_set(movement_tiles, Highlight.Type.Movement)
