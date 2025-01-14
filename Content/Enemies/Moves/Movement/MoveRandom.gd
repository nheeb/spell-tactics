extends EnemyActionLogic

var movement: int
func refresh_movement():
	movement = await combat.action_stack.get_discussion_result(
		args.get_arg(0, enemy.movement_range),
		ActionFlavor.new().set_owner(enemy) \
			.add_tag(ActionFlavor.Tag.Movement).finalize(combat)
	)

func get_random_tile_in_range(enemy_tile: Tile):
	var tiles := enemy_tile.get_surrounding_tiles(movement)
	tiles.shuffle()
	for tile in tiles:
		if tile.is_obstacle():
			continue
		if combat.level.get_shortest_distance(enemy_tile, tile) <= movement:
			return tile
	return enemy_tile

func set_destination_if_invalid(enemy_tile: Tile) -> Tile:
	var destination : Tile = plan.get_detail_and_resolve(combat, 0) as Tile
	if destination:
		if combat.level.get_shortest_distance(enemy_tile, destination) <= movement:
			return destination
	plan.create_detail(0, get_random_tile_in_range(enemy_tile))
	destination = plan.get_detail_and_resolve(combat, 0) as Tile
	if not destination:
		destination = enemy_tile
	return destination

func _setup():
	await refresh_movement()
	set_destination_if_invalid(enemy.current_tile)

func _execute():
	set_destination_if_invalid(enemy.current_tile)
	var destination : Tile = plan.get_detail_and_resolve(combat, 0, enemy.current_tile) as Tile
	var path := combat.level.get_shortest_path(enemy.current_tile, destination)
	for tile in path:
		combat.movement.move_entity(enemy, tile)
		await combat.action_stack.wait()

func _estimated_destination(enemy_tile: Tile) -> Tile:
	return set_destination_if_invalid(enemy_tile)

func _is_possible(enemy_tile: Tile) -> bool:
	await refresh_movement()
	return true
