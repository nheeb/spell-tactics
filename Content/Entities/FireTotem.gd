extends EntityLogic

var damage := 2

func on_birth():
	TimedEffect.new_end_phase_trigger_from_callable(
		deal_damage
	).register(combat)


func deal_damage() -> void:
	var anims = []
	
	for tile in entity.current_tile.get_surrounding_tiles():
		var enemies = tile.get_enemies()
		for enemy in enemies:
			anims.append(enemy.inflict_damage_with_visuals(damage).set_flag_extend())
		if combat.player.current_tile == tile:
			anims.append(combat.player.inflict_damage_with_visuals(damage).set_flag_extend())
	if anims:
		anims.append(combat.animation.wait())
		anims.push_front(combat.animation.say(entity, "Fire Totem Burn").set_delay(.5))
		anims.push_front(combat.animation.camera_reach(entity))
		
		combat.animation.reappend_as_array(anims)
