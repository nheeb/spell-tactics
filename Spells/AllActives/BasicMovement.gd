extends ActiveLogic

## Here should be the effect
func casting_effect() -> void:
	combat.log.add("Move Player to (%d, %d)" % [target.r, target.q])
	var path := combat.level.get_shortest_path(combat.player.current_tile, target)
	var actual_path = []
	for tile in path:
		combat.movement.move_entity(combat.player, tile)
		actual_path.append(combat.player.current_tile)
	
	if len(actual_path) > 0:
		combat.animation.callback(combat.player.visual_entity, "start_walking")
	for tile in actual_path:
		combat.animation.callback(combat.player.visual_entity, "animation_move_to", [tile])
	if len(actual_path) > 0:
		combat.animation.callback(combat.player.visual_entity, "go_idle")

## Can a target tile be selected
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	if _target.is_obstacle(Constants.INT64_MAX):
		return false
	var path = combat.level.get_shortest_path(combat.player.current_tile, _target)
	var length = len(path)
	return length > 0 and length <= combat.player.traits.movement_range

## Set special preview visuals when a target is hovered / selected
func _set_preview_visuals(show: bool, tile: Tile, clicked: bool = false) -> void:
	if show:
		var path = combat.level.get_shortest_path(combat.player.current_tile, tile)
		var length = len(path)
		# check if hovered tile is in movement range, in that case show the movement arrow and
		# highlight the spells, that could be casted from there
		if length > 0 and length <= combat.player.traits.movement_range and not combat.animation.is_playing():
			var positions : Array[Vector3] = [combat.player.current_tile.global_position]
			for t in path:
				positions.append(t.global_position)

			combat.animation.callable(combat.level.immediate_arrows().render_path.bind(positions))
	else:
		combat.animation.callable(combat.level.immediate_arrows().clear)
