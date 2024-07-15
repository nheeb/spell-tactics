class_name EnemyEvent extends CombatEvent

func enemy_event_logic() -> EnemyEventLogic:
	return logic as EnemyEventLogic

func enemy_event_type() -> EnemyEventType:
	return type as EnemyEventType

func get_enemy_meter_costs() -> int:
	return enemy_event_type().enemy_meter_costs

func discover():
	show_info(true)
	combat.animation.wait(1)
	enemy_event_logic().on_discover()
	combat.animation.wait(1)
	show_info(false)

func show_info(visible := true) -> AnimationObject:
	if visible:
		return combat.animation.callable(combat.ui.enemy_event_info.show_event.bind(self))
	else:
		return combat.animation.callable(combat.ui.enemy_event_info.hide)
