extends ActiveLogic

var movement_range: int = 3

func _on_combat_change():
	var flavor := ActionFlavor.new().add_tag(ActionFlavor.Tag.Movement)\
		.set_owner(combat.player).finalize(combat)
	movement_range = await combat.action_stack.get_discussion_result(3, flavor)

func casting_effect() -> void:
	combat.log.add("Move Player to (%d, %d)" % [target.r, target.q])
	var path := combat.level.get_shortest_path_with_memory(combat.player.current_tile, target)
	var actual_path = []
	for tile in path:
		combat.movement.move_entity(combat.player, tile)
		actual_path.append(combat.player.current_tile)
	
	if len(actual_path) > 0:
		combat.animation.call_method(combat.player.visual_entity, "start_walking")
	for tile in actual_path:
		combat.animation.call_method(combat.player.visual_entity, "animation_move_to", [tile])
	if len(actual_path) > 0:
		combat.animation.call_method(combat.player.visual_entity, "go_idle")

## Can a target tile be selected
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	if _target.is_obstacle(Constants.INT64_MAX):
		return false
	var path = combat.level.get_shortest_path(combat.player.current_tile, _target)
	var length = len(path)
	return length > 0 and length <= movement_range

## Set special preview visuals when a target is hovered / selected
func _set_preview_visuals(show: bool, _target: Tile = null, clicked: bool = false) -> void:
	if show:
		if not _is_target_suitable(_target):
			return
		var path = combat.level.get_shortest_path_with_memory(combat.player.current_tile, _target)
		var length = len(path)
		# check if hovered tile is in movement range, in that case show the movement arrow and
		# highlight the spells, that could be casted from there
		if length > 0 and length <= movement_range and not combat.animation.is_playing():
			var positions : Array[Vector3] = [combat.player.current_tile.global_position]
			for t in path:
				positions.append(t.global_position)

			combat.animation.callable(combat.level.immediate_arrows().render_path.bind(positions))
	else:
		combat.animation.callable(combat.level.immediate_arrows().clear)
