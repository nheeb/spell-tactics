extends AbstractPhase

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Enemies attacking..."])
	
	combat.animation.property(combat.camera, "player_input_enabled", false)
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.agility > b.agility)
	
	for enemy in combat.enemies:
		combat.animation.camera_reach(enemy.visual_entity)
		combat.animation.camera_follow(enemy.visual_entity)
		enemy.do_movement()
		combat.animation.wait(.7)
		enemy.do_action()
		combat.animation.camera_unfollow()
		
		combat.player.arch_enemy = enemy.get_reference()
	
	combat.animation.camera_reach(combat.player.visual_entity)
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	return false
