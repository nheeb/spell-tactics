class_name EventSpellLogic extends SpellLogic

## TODO Delete this script

####################
## DEPRECATED !!! ##
####################

## For overriding to give the event length (Could be also moved to SpellRes)
func get_event_length() -> int:
	return 0

func initialize_event() -> void:
	spell.round_persistant_properties["event_current_round"] = 0
	
	for i in range(get_event_length()):
		var entry : LogEntry = combat.log.create_and_register_entry(\
								"", LogEntry.Type.EventPrognose)
		entry.round_number = combat.current_round + i
		entry.number = 1 + i
		entry.spell = spell.get_reference()
		combat.ui.timeline.log_entry_queue.append(entry)

## Processes the next round of the event. Returns true if the event is done
func advance_event() -> bool:
	spell.round_persistant_properties["event_current_round"] += 1
	
	var round_number : int = spell.round_persistant_properties["event_current_round"]
	var event_name := spell.type.pretty_name
	var effect_text := spell.type.effect_text
	combat.animation.callback(combat.ui, "set_status", ["Event %s (Round %s)\n%s" % [event_name, round_number, ""] ])
	combat.animation.callback(combat.ui.cards3d, "show_event", [spell.type, round_number]).set_min_duration(4.5)
	
	# Animate timeline
	var entry := combat.log.create_and_register_entry("", LogEntry.Type.Event)
	entry.number = round_number
	entry.spell = spell.get_reference()
	combat.ui.timeline.log_entry_queue.append(entry)
	combat.animation.callable(combat.ui.timeline.process_log_entry_queue)
	
	event_effect(round_number)
	
	combat.animation.callback(combat.ui.cards3d, "hide_event").set_delay(1.5)
	if spell.round_persistant_properties["event_current_round"] >= get_event_length():
		finalize_event()
		return true
	return false

## Most important function for overwriting. Here should be the event effect
func event_effect(round_number: int) -> void:
	pass

func finalize_event() -> void:
	spell.round_persistant_properties.erase("event_current_round")
