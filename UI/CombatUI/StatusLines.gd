class_name StatusLines extends Control

@export var color: Color

const LABEL_SETTINGS = preload("res://UI/ErrorMessageLabelSettings.tres")

func clear():
	hide()
	for c in $VBoxContainer.get_children():
		c.queue_free()

func add(text: String):
	show()
	var label = Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = text
	#label.modulate = color
	label.label_settings = LABEL_SETTINGS
	$VBoxContainer.add_child(label)


func _ready() -> void:
	clear()
