class_name EventUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

var events: Array[Spell]
var current_event: SpellReference

func process_event() -> void:
	if current_event == null:
		current_event = events.pick_random().get_reference()
		current_event.resolve(combat).event_logic.initialize_event()
	if current_event.resolve(combat).event_logic.advance_event():
		current_event = null
