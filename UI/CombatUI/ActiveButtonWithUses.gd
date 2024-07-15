class_name ActiveButtonWithUses extends Control

@onready var button = $ActiveButton


var active: Active = null:
	set(new_active):
		var old_active = active
		active = new_active
	
		if is_inside_tree() and old_active == null:
			init_active(new_active)
@onready var bubbles: Array[ActiveUseBubble] = [$ActiveUseBubble1, $ActiveUseBubble2, $ActiveUseBubble3]

const TWO_BUBBLES_OFFSET: Vector2 = Vector2(8.0, -8.0)
#func update_active(new_active: Active):
	
func _ready() -> void:
	if active != null:
		init_active(active)
				

func init_active(new_active: Active): 
	#print("new_active %s connected.", active.type.pretty_name)
	new_active.got_updated.connect(_on_active_uses_updated)

	button.icon.texture = new_active.type.icon

	var max_uses = new_active.get_limitation_max_uses()
	assert(len(bubbles) == 3, "Expecting original bubbles array")
	match max_uses:
		1:
			var bubble3 = bubbles.pop_back()
			var bubble2: ActiveUseBubble = bubbles.pop_back()
			var central_bubble_pos: Vector2 = bubble2.position
			bubble3.queue_free()
			bubble2.queue_free()
			bubbles[0].position = central_bubble_pos
		2:
			var bubble3 = bubbles.pop_back()
			var bubble2 = bubbles[1]
			var bubble1 = bubbles[0]
			bubble3.queue_free()

			bubble2.position += Vector2(-TWO_BUBBLES_OFFSET.x, TWO_BUBBLES_OFFSET.y)
			bubble1.position += TWO_BUBBLES_OFFSET
		3:
			pass # do nothing
		_: 
			printerr("Active %s  max_uses = %d" % [new_active.type.pretty_name, max_uses])
	
func _on_active_uses_updated():
	var uses_left = active.get_limitation_uses_left()
	var max_uses = active.get_limitation_max_uses() # TODO read max_uses and double-check the following logic
	
	assert(max_uses == len(bubbles))

	for i in range(uses_left):
		bubbles[i].enabled = true
		
	for i in range(uses_left, max_uses):
		bubbles[i].enabled = false
		


func _on_mouse_entered() -> void:
	if Game.world != null:
		Game.world.get_node("%MouseRaycast").disabled = true


func _on_mouse_exited() -> void:
	if Game.world != null:
		Game.world.get_node("%MouseRaycast").disabled = false
