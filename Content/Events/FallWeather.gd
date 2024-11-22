extends CombatEventLogic

func _on_advance(round_number: int) -> void:
	var create := event.persistant_properties.get("create", true) as bool
	if create:
		combat.animation.wait(1.5)
		event.update_ui_icon(false)
		var weather_type = event.params["weather_pool"].pick_random()
		var new_event = weather_type.create_event(combat)
		combat.events.add_event_and_activate(new_event, true)
	else:
		event.update_ui_icon(true)
		combat.animation.wait(1.2)
	event.persistant_properties["create"] = not create
