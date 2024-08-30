extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)
## targets - Array of target tiles (if Spell has multiple targets)


## Here should be the effect
func casting_effect() -> void:
	pass

## Change the spells costs
#func _get_costs() -> EnergyStack:
	#return spell.type.costs

## Spell can be selected
#func _is_selectable() -> bool:
	#return true

## Spell can be casted
#func _is_castable() -> bool:
	#return true

## Can a target tile be selected
#func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	#return true

## Visuals or something else on spell select / deselect
#func _on_select_deselect(select: bool) -> void:
	#pass

## Does the spell take additional targets
#func _are_targets_full(_targets: Array[Tile]) -> bool:
	#return true

## Are the selected targets valid
#func _are_targets_castable(_targets: Array[Tile]) -> bool:
	#return true

## Set special preview visuals when a target is hovered / selected
#func _set_preview_visuals(show: bool, _target: Tile, active: bool) -> void:
	#pass
