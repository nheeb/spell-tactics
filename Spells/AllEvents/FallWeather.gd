extends CombatEventLogic

func _on_advance(round_number: int) -> void:
	var current_weather_ref := event.persistant_properties.get("current_weather") \
			as CombatEventReference
	if current_weather_ref:
		var _event := current_weather_ref.get_event(combat)
		if _event.finished:
			start_new_weather()
	else:
		start_new_weather()

func start_new_weather():
	combat.animation.wait(2)
	var weather_type = event.params["weather_pool"].pick_random() as CombatEventType
	var new_event = weather_type.create_event(combat)
	event.persistant_properties["current_weather"] = new_event
	combat.events.add_event_and_activate(new_event, true)

