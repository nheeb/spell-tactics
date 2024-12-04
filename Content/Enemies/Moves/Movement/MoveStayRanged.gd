extends EnemyActionLogic

var movement: int

func _setup():
	movement = await combat.action_stack.get_discussion_result(
		args.get_arg(0, enemy.movement_range),
		ActionFlavor.new().set_owner(enemy) \
			.add_tag(ActionFlavor.Tag.Movement).finalize(combat)
	)

func get_path(enemy_tile: Tile) -> Array[Tile]:
	var range_target := target_tile
	if range_target == null:
		range_target = combat.player.current_tile
	assert(range_target)
	var tiles_in_range := enemy_tile.get_tiles_in_walking_range(movement)
	# Sort tiles by which have least cover in their line to the target (player)
	Utility.array_sort(
		tiles_in_range, 
		func(t: Tile):
			var line := combat.level.get_line(t, range_target)
			var cover: int = line.reduce(
				func (accum: int, tt: Tile) -> int:
					return tt.get_highest_cover()
					, 0)
			var distance := t.distance_to(range_target)
			var distance_margin: int = abs(4 - distance)
			return float(cover) + .3 * distance_margin
	)
	var destination := Utility.array_safe_get(tiles_in_range, 0) as Tile
	if destination:
		var path := combat.level.get_shortest_path(enemy_tile, destination)
		assert(path.size() <= movement)
		return path
	return []

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

func _estimated_destination(enemy_tile: Tile) -> Tile:
	return get_path_end(enemy_tile)
