@tool
extends Control

@export var texture: Texture2D
@export var text: String

@onready var label: Label = $Label
@onready var button: Button = $"Button"

signal pressed

func _ready():
	label.text = text
	button.icon = texture

func _on_button_pressed():
	pressed.emit()
