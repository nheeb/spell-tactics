class_name ActiveUseBubble extends Control

@export var enabled_color: Color = Color("63dad0")
@export var highlight_color: Color = Color("c9fffd")
@export var disabled_color: Color = Color("444444")

@onready var circle = %Circle
var highlighted: bool = false:
	set(now_highlighted):
		if now_highlighted and enabled:
			circle.color = highlight_color
		if not now_highlighted:
			circle.color = enabled_color if enabled else disabled_color
		highlighted = now_highlighted
var enabled: bool = true:
	set(now_enabled):
		if enabled and not now_enabled:
			# switch off
			circle.color = disabled_color
			circle.material.set_shader_parameter("icon_color", Color("afafaf"))
		if not enabled and now_enabled:
			# switch on
			circle.color = enabled_color
			circle.material.set_shader_parameter("icon_color", Color.WHITE)
			
		enabled = now_enabled
