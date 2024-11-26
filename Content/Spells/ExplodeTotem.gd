extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)
## targets - Array of target tiles (if Spell has multiple targets)
var damage = 2

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	#var totem = target.entities.filter(
	#func (e: Entity):
	#	return "summoned" in e.get_tags()
	#)
	for e in target.entities:
		if "summoned" in e.get_tags():
			var totem = e
			totem.die()
	#TODO make Totems disappear
	
		
	var anims = []
	for tile in target.get_surrounding_tiles():
		anims.append(combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.RED}).set_duration(0.1))
		anims.append(combat.animation.show(tile).set_flag_with())
		var enemies = tile.get_enemies()
		for enemy in enemies:
			anims.append(enemy.inflict_damage_with_visuals(damage).set_flag_extend())
		if combat.player.current_tile == tile:
			anims.append(combat.player.inflict_damage_with_visuals(damage).set_flag_extend())
	if anims:
		anims.append(combat.animation.wait())
		#anims.push_front(combat.animation.say(target, "Explode Totem Damage").set_delay(.5))
		anims.push_front(combat.animation.camera_reach(target))
		
		combat.animation.reappend_as_array(anims)
	
	
	
	

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
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	target = _target as Tile
	for e in target.entities:
		if "summoned" in e.get_tags():
			return true
	return false

## Visuals or something else on spell select / deselect
#func _on_select_deselect(select: bool) -> void:
	#pass

## Does the spell take additional targets
#func _are_targets_full(_targets: Array[Tile]) -> bool:
	#return true

## Are the selected targets valid
#func _are_targets_castable(_targets: Array[Tile]) -> bool:

#	return false

## Set special preview visuals when a target is hovered / selected
#func _set_preview_visuals(show: bool, _target: Tile = null, active: bool) -> void:
	#pass
