extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy, "We need more goblins!")
	if not combat.events.current_enemy_event:
		await combat.action_stack.process_callable(
			combat.events.discover_next_enemy_event
		)
	combat.events.add_to_enemy_meter(args.get_arg(0, 1))
