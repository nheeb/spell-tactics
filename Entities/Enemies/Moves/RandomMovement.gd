extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 1.0

## Executes the move
func execute() -> void:
	var tiles_in_range := combat.level.get_all_tiles_in_distance_of_tile(enemy.current_tile, 2)
	tiles_in_range = tiles_in_range.filter(func(tile): return not tile.is_obstacle())
	if not tiles_in_range.is_empty():
		var target: Tile = tiles_in_range.pick_random() as Tile
		var path := combat.level.get_shortest_path(enemy.current_tile, target)
		var max_dist := 3
		for tile in path:
			combat.movement.move_entity(enemy, tile)
			max_dist -= 1
			if max_dist == 0:
				break
