extends VisualEntity

@export var count: int = 4:
	set(c):
		var children = get_children()
		for ch in children:
			ch.visible = false
		for i in range(c):
			children[i].visible = true
		count = c
			


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
