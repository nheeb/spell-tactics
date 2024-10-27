extends EnemyActionLogic

func _execute():
	combat.animation.say(enemy, "We need more goblins!")
	combat.events.add_to_enemy_meter(args.get_arg(0, 1))
