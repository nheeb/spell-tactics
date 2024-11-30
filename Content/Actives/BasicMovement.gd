extends ActiveLogic

var movement_range: int = 3

func on_birth():
	TimedEffect.new_combat_change(on_combat_change) \
		.set_id("_cc").set_solo().register(combat)

func on_combat_change():
	var flavor := ActionFlavor.new().add_tag(ActionFlavor.Tag.Movement) \
		.set_owner(combat.player).finalize(combat)
	movement_range = await combat.action_stack.get_discussion_result(3, flavor)

func execute() -> void:
	combat.log.add("Move Player to (%d, %d)" % [target_tile.r, target_tile.q])
	var path := combat.level.get_shortest_path_with_memory(combat.player.current_tile, target_tile)
	var actual_path = []
	for tile in path:
		combat.movement.move_entity(combat.player, tile, false)
		actual_path.append(combat.player.current_tile)
	
	if len(actual_path) > 0:
		combat.animation.call_method(combat.player.visual_entity, "start_walking")
	for tile in actual_path:
		combat.animation.call_method(combat.player.visual_entity, "animation_move_to", [tile])
	if len(actual_path) > 0:
		combat.animation.call_method(combat.player.visual_entity, "go_idle")

## Can a target tile be selected
func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	target = target as Tile
	var path = combat.level.get_shortest_path(actor.current_tile, target)
	var length = len(path)
	return length > 0 and length <= movement_range

## Set special preview visuals when a target is hovered / selected
func set_preview_visuals(show: bool, tile: Tile = null) -> void:
	if show:
		if not actor:
			return
		if not active.is_target_valid(tile):
			return
		var path = combat.level.get_shortest_path_with_memory(combat.player.current_tile, tile)
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
