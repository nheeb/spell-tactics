class_name EnemyEvent extends CombatEvent

func enemy_event_logic() -> EnemyEventLogic:
	return logic as EnemyEventLogic

func discover():
	enemy_event_logic().on_discover()

func show_info(show := true):
	pass
