extends SpellLogic

## Usable references:
## spell - Corresponding spell (CombatObject with data)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)
## targets - Array of target tiles (if Spell has multiple targets)
var damage := 3

## Here should be the effect
func execute() -> void:
	assert(target_tiles.size() == 2)
	var source_tile := target_tiles[0]
	var destination_tile := target_tiles[1]
	var ents := source_tile.entities.filter(func(e: Entity): return "summoned" in e.get_tags())
	var enemies := destination_tile.get_enemies()
	
	
	for ent in ents:
		combat.movement.blink_entity(ent, destination_tile).set_flag_with()
		for enemy in enemies:
			enemy.inflict_damage_with_visuals(damage)
	


	
	

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
#func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	#return true

## Visuals or something else on spell select / deselect
#func on_select_deselect(select: bool) -> void:
	#pass

## Set special preview visuals when a target is hovered / selected
#func set_preview_visuals(show: bool, tile: Tile = null) -> void:
	#pass
