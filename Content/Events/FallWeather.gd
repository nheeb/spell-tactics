extends CombatEventLogic

func _on_advance(round_number: int) -> void:
	var create := event.data.get("create", true) as bool
	if create:
		combat.animation.wait(1.5)
		event.update_ui_icon(false)
		var weather_pool: Array = event.data.get_or_add("weather_pool", []) as Array
		var weather_type := weather_pool.pick_random() as CombatEventType
		if weather_type:
			var new_event = weather_type.create_event(combat)
			await combat.events.add_event_and_activate(new_event, true)
		else:
			push_error("Add types to the weather_pool data entry")
	else:
		event.update_ui_icon(true)
		combat.animation.wait(1.2)
	event.data["create"] = not create
