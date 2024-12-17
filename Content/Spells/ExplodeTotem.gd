extends SpellLogic

var damage = 3

## Here should be the effect
func execute() -> void:
	var totem_array: Array = target_tile.entities.filter(
		func (e: Entity):
			return "summoned" in e.get_tags()
	)
	
	assert(totem_array)
	var totem = totem_array.front()
	totem.die()

	var anims = []
	for tile in target_tile.get_surrounding_tiles():
		anims.append(combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.RED}).set_duration(0.1))
		anims.append(combat.animation.show(tile).set_flag_with())
		var enemies = tile.get_enemies()
		for enemy in enemies:
			anims.append(enemy.inflict_damage_with_visuals(damage).set_flag_extend())
		if combat.player.current_tile == tile:
			anims.append(combat.player.inflict_damage_with_visuals(damage).set_flag_extend())
	if anims:
		anims.append(combat.animation.wait())
		anims.push_front(combat.animation.camera_reach(target_tile))
		combat.animation.reappend_as_array(anims)

## Can a target tile be selected
func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	for e in target.entities:
		if "summoned" in e.get_tags():
			return true
	return false
