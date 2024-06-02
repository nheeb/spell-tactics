class_name AttackUtility extends CombatUtility

func enemy_shoot_projectile(enemy: EnemyEntity, projectile_bonus := 0, texture_name := "arrow") -> bool:
	combat.animation.wait(.5)
	var line := combat.level.get_line(enemy.current_tile, combat.player.current_tile)
	if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
		combat.animation.wait(1.0)
		combat.animation.effect(VFX.LINE, enemy.current_tile, {"start_node": enemy.current_tile, "end_node": combat.player.current_tile, "duration": 2.0}).set_max_duration(.1)
	var total_cover := 0
	for tile in line:
		if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
			combat.animation.effect(VFX.HEX_COLOR, tile).set_flag_with()
		for ent in tile.entities:
			var cover := ent.type.cover_value
			if cover != 0:
				total_cover += cover
				if DebugInfo.SHOW_ENEMY_PROJECTILE_INFO:
					combat.animation.say(tile, "[%s]" % cover).set_flag_with().set_delay(.9)
	
	var chance : float = clamp(enemy.accuracy * 10.0 + projectile_bonus * 10.0 - total_cover * 10.0, 0.0, 100.0)

	combat.animation.say(enemy.visual_entity, "Shooting! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, \
		 {"color": Color.RED}).set_flag_with()
	combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {"texture_name": texture_name, "target": combat.player.visual_entity}).set_flag_extend()
	combat.animation.camera_reach(combat.player.visual_entity).set_flag_extend()
	
	var hit := Utility.random_hit(chance)
	return hit

func enemy_punch(enemy: EnemyEntity, attack_bonus := 0) -> bool:
	var chance : float = max(0.0, attack_bonus * 10.0 + enemy.accuracy * 10.0)

	combat.animation.say(enemy.visual_entity, "Punching! (%.0f%% hit chance)" % chance)
	combat.animation.effect(VFX.HEX_RINGS, combat.player.current_tile, {"color": Color.RED}).set_flag_with()
	
	var hit := Utility.random_hit(chance)
	return hit

func get_other_enemies(enemy: EnemyEntity) -> Array[EnemyEntity]:
	var enemies := combat.get_all_enemies()
	return enemies.filter(func(e): return e != enemy)
