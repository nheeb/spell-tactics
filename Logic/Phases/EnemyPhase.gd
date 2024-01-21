extends AbstractPhase

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Enemies attacking..."])
	
	combat.animation.property(combat.camera, "player_input_enabled", false)
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.type.agility > b.type.agility)
	
	for enemy in combat.enemies:
		combat.animation.property(combat.camera, "follow_target", enemy.visual_entity)
		combat.animation.wait(1).set_flag(AnimationObject.Flags.ExtendStep)
		enemy.do_movement()
		enemy.do_action()
		combat.animation.property(combat.camera, "follow_target", null)
		
		combat.player.arch_enemy = enemy.get_reference()
	
	combat.animation.property(combat.camera, "player_input_enabled", true)
	
	return false
