class_name TimelineEventIcon extends Node2D

const BASE_SIZE_PIXEL = 256

@onready var timeline: TimelineUI = get_parent().get_parent().get_parent()

var log_entry: LogEntry
var type: SpellType
var alpha := 1.0:
	set(x):
		alpha = clamp(x, 0.0, 1.0)
		visible = alpha != 0.0
		%TextureRect.modulate.a = alpha
		%SubLabel.label_settings.font_color.a = alpha

func set_log_entry(_log_entry: LogEntry, combat: Combat = null):
	log_entry = _log_entry
	assert(log_entry.spell)
	assert(log_entry.type == LogEntry.Type.Event or \
		   log_entry.type == LogEntry.Type.EventPrognose)
	set_event_type(log_entry.spell.get_spell(combat).type)
	set_sub_label(str(log_entry.number))
	if log_entry.type == LogEntry.Type.EventPrognose:
		%TextureRect.modulate = Color.GRAY
	else:
		%TextureRect.modulate = type.color
	%TextureRect.modulate.a = alpha

func set_event_type(_type: SpellType):
	type = _type
	%TextureRect.texture = type.icon
	if %TextureRect.texture:
		%TextureRect.scale = Vector2.ONE * \
							(float(BASE_SIZE_PIXEL) / %TextureRect.texture.get_width())

func set_sub_label(text: String):
	%SubLabel.text = text
	%SubLabel.show()

func _ready() -> void:
	%SubLabel.hide()

func _on_area_2d_mouse_entered() -> void:
	if visible and type:
		var number := int(%SubLabel.text)
		if number <= 0:
			number = -1
		timeline.combat_ui.cards3d.show_event(type, number, 2.0)

func _on_area_2d_mouse_exited() -> void:
	if visible and type:
		var number := int(%SubLabel.text)
		if number <= 0:
			number = -1
		if timeline.combat_ui.cards3d.is_event_currently_shown(type, number):
			timeline.combat_ui.cards3d.hide_event()

