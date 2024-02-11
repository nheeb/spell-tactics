class_name EventUtility extends CombatUtility

var events: Array[Spell]
var current_event: SpellReference

func process_event() -> void:
	if events.is_empty():
		combat.log.add("No Events loaded")
		return
	if current_event == null:
		current_event = events.pick_random().get_reference()
		current_event.resolve(combat).event_logic.initialize_event()
	
	if current_event.resolve(combat).event_logic.advance_event():
		current_event = null
