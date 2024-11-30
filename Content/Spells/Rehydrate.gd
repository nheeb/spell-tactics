extends SpellLogic

## Usable references:
## active - Corresponding active
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the active was created
## target - The target Tile (if active is targetable)
## targets - Array of target tiles (if active has multiple targets)


## Here should be the effect



func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	for enemy in _target.get_enemies():
		if enemy.get_status("Wet"):
			return true
	return false



func casting_effect() -> void:			
	target_enemy.remove_status("Wet")
	target = target as Tile
	var enemies = target.get_enemies()
	for enemy in enemies:
		enemy = enemy as EnemyEntity
		if enemy.get_status_effect("Wet"):
			enemy.remove_status("Wet")
	combat.energy.gain(EnergyStack.string_to_energy("H"), combat.player)
	combat.cards.draw()
	combat.cards.draw()

			
			
	
			

			

## active can be selected
#func _is_selectable() -> bool:
	#return true

## active can be casted
#func _is_castable() -> bool:
	#return true

## Can a target tile be selected
#func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	#return true

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
#func _set_preview_visuals(show: bool, _target: Tile = null, active: bool) -> void:
	#pass

## Use this to calculate values that depend on the current game state
#func _update_current_state() -> void:
	#pass
