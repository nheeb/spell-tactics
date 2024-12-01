class_name StatusLines extends Control

@export var default_color: Color

const LABEL_SETTINGS = preload("res://UI/Theme/LabelSettings/BoldItalicOutline.tres")
#preload("res://UI/Theme/LabelSettings/ErrorMessageLabelSettings.tres")

func clear():
	hide()
	for c in $VBoxContainer.get_children():
		c.queue_free()

func add(text: String, color := default_color):
	show()
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = text
	label.modulate = color
	label.label_settings = LABEL_SETTINGS
	$VBoxContainer.add_child(label)

func _ready() -> void:
	clear()
