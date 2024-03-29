class_name TimelineEventIcon extends Node2D

var type: SpellType

func set_event_type(_type: SpellType):
	
	%TextureRect.texture = type.icon
