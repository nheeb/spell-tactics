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
	
	
	
	



## Can a target tile be selected
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	target = _target as Tile
	for e in target.entities:
		if "summoned" in e.get_tags():
			return true
	return false
