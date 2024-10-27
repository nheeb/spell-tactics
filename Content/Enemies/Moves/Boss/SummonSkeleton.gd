extends EnemyActionLogic

const SKELETON = preload("res://Entities/Enemies/SkeletonTrooper.tres")

func get_free_adjacent_tile(enemy_tile: Tile) -> Tile:
	var surrounding_tiles := enemy_tile.get_surrounding_tiles().filter(
		func (t: Tile):
			return not t.is_blocked()
	)
	var dir_tile : Tile = target_tile if target_tile \
		else combat.player.current_tile
	surrounding_tiles.sort_custom(
		func (a: Tile, b: Tile):
			return a.distance_to(dir_tile) < b.distance_to(dir_tile)
	)
	if surrounding_tiles:
		return surrounding_tiles.front()
	return null

func _execute():
	await combat.action_stack.process_callable(combat.attack.summon_enemy.bind(
		SKELETON, get_free_adjacent_tile(enemy.current_tile)
	))

func _is_possible(enemy_tile: Tile) -> bool:
	return get_free_adjacent_tile(enemy_tile) != null
