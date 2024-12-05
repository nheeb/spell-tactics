class_name EnemyPhase extends CombatPhase

func process_phase() -> void:
	combat.animation.call_method(combat.ui, "set_status", ["Enemies attacking..."])
	combat.animation.property(combat.camera, "player_input_enabled", false)
	# Player can not idle from this phase on
	# Player camera input will be reenabled in the end phase
	combat.animation.call_method(combat.player.visual_entity, "stop_idling")
	combat.ui.disable_actions()
	for active in combat.actives:  # can't trigger any actives
		active.unlocked = false
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.agility > b.agility)
	
	for enemy in combat.enemies:
		combat.action_stack.preset_combat_change()
		combat.action_stack.preset_flavor(
			ActionFlavor.new().set_owner(enemy) \
				.add_tag(ActionFlavor.Tag.EnemyActionGeneric)
				.finalize(combat)
		)
		combat.action_stack.process_ticket(
			ActionTicket.new(do_enemy_action.bind(enemy))
		)
		
		await combat.action_stack.wait()
		
		combat.animation.callable(enemy.visual_entity.look_at_entity_tile_border.bind(combat.player))\
			.add_wait_ticket_to_args()
	# nils - should we really wait here?
	combat.animation.wait(.7)

## ACTION
func do_enemy_action(enemy: EnemyEntity):
	combat.animation.camera_reach(enemy.visual_entity)
	combat.animation.camera_follow(enemy.visual_entity)
	combat.animation.wait(.2)
	await enemy.do_action()
	combat.animation.camera_unfollow()
