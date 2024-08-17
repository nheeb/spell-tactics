extends AbstractPhase

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Enemies attacking..."])
	combat.animation.property(combat.camera, "player_input_enabled", false)
	# player can not idle from this phase on
	combat.animation.callback(combat.player.visual_entity, "stop_idling")
	combat.ui.disable_actions()
	for active in combat.actives:  # can't trigger any actives
		active.unlocked = false
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.agility > b.agility)
	
	for enemy in combat.enemies:
		combat.animation.camera_reach(enemy.visual_entity)
		combat.animation.camera_follow(enemy.visual_entity)
		combat.animation.wait(.2)
		enemy.do_action()
		combat.animation.camera_unfollow()
		
		if combat.player.is_dead():
			break
	
	# Player camera input will be reenabled in the end phase
	
	return false
