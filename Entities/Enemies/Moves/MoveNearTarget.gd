extends EnemyActionLogic

var movement: int:
	get:
		return args.get_arg(0, enemy.movement_range)

func get_path(enemy_tile: Tile) -> Array[Tile]:
	var path := combat.level.get_shortest_path(enemy_tile, target_tile)
	if not path.is_empty():
		path.pop_back()
	else:
		path.append(enemy_tile.get_surrounding_tiles().pick_random())
	return path.slice(0, movement)

func get_path_end(enemy_tile: Tile) -> Tile:
	var path := get_path(enemy_tile)
	if not path.is_empty():
		return path[-1]
	return enemy_tile

func _execute():
	var path := get_path(enemy.current_tile)
	for tile in path:
		combat.movement.move_entity(enemy, tile)
		await combat.action_stack.wait()

func _is_possible(enemy_tile) -> bool:
	return enemy_tile.distance_to(target.current_tile) != 1

func _estimated_destination(enemy_tile: Tile) -> Tile:
	return get_path_end(enemy_tile)
