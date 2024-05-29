class_name StatusLines extends Control

@export var color: Color

const LABEL_SETTINGS = preload("res://UI/DefaultLabelSettings.tres")

func clear():
	hide()
	for c in $VBoxContainer.get_children():
		c.queue_free()

func add(text: String):
	show()
	var label = Label.new()
	$VBoxContainer.add_child(label)
	label.text = text
	label.modulate = color
	label.label_settings = LABEL_SETTINGS

func _ready() -> void:
	clear()
