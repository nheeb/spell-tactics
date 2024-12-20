extends EntityLogic

var duration := 3
var damage := 2

func on_birth():
	TimedEffect.new_enemy_phase_trigger_from_callable(make_damage) \
			.set_trigger_count(duration) \
			.extra_last_callable(entity.die) \
			.register(combat)

func make_damage():
	var anims = []
	
	for tile in entity.current_tile.get_surrounding_tiles():
		var enemies = tile.get_enemies()
		for enemy in enemies:
			anims.append(enemy.inflict_damage_with_visuals(damage).set_flag_extend())
		if combat.player.current_tile == tile:
			anims.append(combat.player.inflict_damage_with_visuals(damage).set_flag_extend())
	
	if anims:
		anims.push_front(combat.animation.wait())
		anims.push_front(combat.animation.say(entity, "Cyclone Damage").set_delay(.5))
		anims.push_front(combat.animation.camera_reach(entity))
		
		combat.animation.reappend_as_array(anims)
