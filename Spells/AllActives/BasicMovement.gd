extends ActiveLogic

## Usable references:
## active - Corresponding active
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the active was created
## target - The target Tile (if active is targetable)
## targets - Array of target tiles (if active has multiple targets)


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

## active can be selected
#func _is_selectable() -> bool:
	#return true

## active can be casted
#func _is_castable() -> bool:
	#return true

## Can a target tile be selected
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	if _target.is_obstacle(Constants.INT64_MAX):
		return false
	var path = combat.level.get_shortest_path(combat.player.current_tile, _target)
	var length = len(path)
	return length > 0 and length <= combat.player.traits.movement_range

## Visuals or something else on active select / deselect
#func _on_select_deselect(select: bool) -> void:
	#pass

## Does the active take additional targets
#func _are_targets_full(_targets: Array[Tile]) -> bool:
	#return true

## Are the selected targets valid
#func _are_targets_castable(_targets: Array[Tile]) -> bool:
	#return true

## Set special preview visuals when a target is hovered / selected
func _set_preview_visuals(tile: Tile, clicked: bool = false) -> void:
	var path = combat.level.get_shortest_path(combat.player.current_tile, tile)
	var length = len(path)
	# check if hovered tile is in movement range, in that case show the movement arrow and
	# highlight the spells, that could be casted from there
	if length > 0 and length <= combat.player.traits.movement_range and not combat.animation.is_playing():
		var positions : Array[Vector3] = [combat.player.current_tile.global_position]
		for t in path:
			positions.append(t.global_position)

		combat.level.immediate_arrows().render_path(positions)
		#highlight_payable_spells(tile)

