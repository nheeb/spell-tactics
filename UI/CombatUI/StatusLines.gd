class_name StatusLines extends Control

@export var color: Color

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

func _ready() -> void:
	clear()
