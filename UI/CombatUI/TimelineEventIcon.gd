class_name TimelineEventIcon extends Node2D

var log_entry: LogEntry
var type: SpellType

func set_log_entry(_log_entry: LogEntry, combat: Combat = null):
	log_entry = _log_entry
	assert(log_entry.spell)
	set_event_type(log_entry.spell.get_spell(combat).type)

func set_event_type(_type: SpellType):
	%TextureRect.texture = type.icon

func set_sub_label(text: String):
	%SubLabel.text = text
