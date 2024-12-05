extends SpellLogic

func execute() -> void:
	pass
	#target = target as Tile
	#var decay_energy := combat.energy.player_energy.count(EnergyStack.EnergyType.Decay)
	#var total_damage = 3 + 3 * int(bool(decay_energy))
	#for enemy in target.get_enemies():
		#enemy = enemy as EnemyEntity
		#combat.animation.say(enemy.visual_entity, "%s Damage" % total_damage,\
		 #{"color": Color.RED, \
		#"font_size": 64 + int(Utility.clamp_map(total_damage, 1, 6, 0, 64))}).set_duration(.5)
		#enemy.inflict_damage_with_visuals(total_damage)
