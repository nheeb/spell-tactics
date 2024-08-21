extends AbstractPhase

func process_phase() -> void:
	combat.animation.callback(combat.ui, "set_status", ["Enemies attacking..."])
	combat.animation.property(combat.camera, "player_input_enabled", false)
	# Player can not idle from this phase on
	# Player camera input will be reenabled in the end phase
	combat.animation.callback(combat.player.visual_entity, "stop_idling")
	combat.ui.disable_actions()
	for active in combat.actives:  # can't trigger any actives
		active.unlocked = false
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.agility > b.agility)
	
	for enemy in combat.enemies:
		combat.action_stack.push_back(
			ActionTicket.new(do_enemy_action.bind(enemy))
		)
	await combat.action_stack.clear

func do_enemy_action(enemy: EnemyEntity):
	combat.animation.camera_reach(enemy.visual_entity)
	combat.animation.camera_follow(enemy.visual_entity)
	combat.animation.wait(.2)
	enemy.do_action()
	combat.animation.camera_unfollow()
