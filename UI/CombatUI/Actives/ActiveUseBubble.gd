class_name ActiveUseBubble extends Control

@export var enabled_color: Color = Color("63dad0")
@export var disabled_color: Color = Color("444444")

@onready var circle = %Circle

var enabled: bool = true:
	set(now_enabled):
		if enabled and not now_enabled:
			# switch off
			circle.color = disabled_color
		if not enabled and now_enabled:
			# switch on
			circle.color = enabled_color
			
		enabled = now_enabled

