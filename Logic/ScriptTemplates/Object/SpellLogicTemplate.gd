extends SpellLogic

## Usable references:
## spell - Corresponding spell (CombatObject with data)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)
## targets - Array of target tiles (if Spell has multiple targets)


## Here should be the effect
func execute() -> void:
	pass

## Change the spells costs
#func _get_costs() -> EnergyStack:
	#return spell.type.costs

## Spell can be selected
#func is_selectable() -> bool:
	#return true

## Spell can be casted
#func is_castable() -> bool:
	#return true

## Can a target tile be selected
#func is_target_valid(target: Variant, requirement: TargetRequirement, _actor: Entity) -> bool:
	#return true

## Visuals or something else on spell select / deselect
#func on_select_deselect(select: bool) -> void:
	#pass

## Set special preview visuals when a target is hovered / selected
#func set_preview_visuals(show: bool, tile: Tile = null) -> void:
	#pass
