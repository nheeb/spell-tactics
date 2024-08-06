class_name ActiveButtonWithUses extends Control

const MAX_USES: int = 3
## how much to move when having 2 instead of 3 active use bubbles
const TWO_BUBBLES_OFFSET: Vector2 = Vector2(8.0, -8.0)
const ACTIVE_USE_BUBBLE = preload("res://UI/CombatUI/Actives/ActiveUseBubble.tscn")

@onready var button = $ActiveButton
@onready var bubbles: Array[ActiveUseBubble] = [$ActiveUseBubble1, $ActiveUseBubble2, $ActiveUseBubble3]
@onready var positions: Array[Marker2D] = [$Position1, $Position2, $Position3]

var combat

var active: Active = null:
	set(new_active):
		var old_active = active
		active = new_active
	
		if is_inside_tree() and old_active == null:
			new_active.got_updated.connect(_on_active_uses_updated)
			init_active(new_active)

func _ready() -> void:
	if active != null:
		active.got_updated.connect(_on_active_uses_updated)
		init_active(active)
	else:
		push_warning("no active set on initializing ActiveButton")


func restart_bubbles():
	while not bubbles.is_empty():
		var bubble_to_delete = bubbles.pop_back()
		bubble_to_delete.free()
	
	#await get_tree().process_frame
	
	var bubble: ActiveUseBubble
	for i in range(MAX_USES):
		bubble = ACTIVE_USE_BUBBLE.instantiate()
		bubble.name = "ActiveUseBubble%d" % (i+1)
		
		add_child(bubble)
		bubble.position = get_node("Position" + str(i+1)).position
		bubbles.append(bubble)



func init_active(new_active: Active): 
	button.icon.texture = new_active.type.icon

	var max_uses = new_active.get_limitation_max_uses()
	assert(len(bubbles) == MAX_USES, "Expecting original bubbles array")
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
			push_error("Active %s  max_uses = %d. weird, huh?" % [new_active.type.pretty_name, max_uses])
	
func _on_active_uses_updated():
	var uses_left: int = active.get_limitation_uses_left()
	var max_uses: int = active.get_limitation_max_uses() # TODO read max_uses and double-check the following logic
	
	# check if we should update bubble count
	if(max_uses != len(bubbles)):
		if max_uses > len(bubbles):
			restart_bubbles()
		init_active(active)

	# set bubbles enabled/disabled
	for i in range(uses_left):
		bubbles[i].enabled = true
		
	for i in range(uses_left, max_uses):
		bubbles[i].enabled = false
		


func _on_mouse_entered() -> void:
	# TODO doesn't seem to have the desired effect! (still showing tile hover effect)
	# TODO RayCast.register_new_blocker() -> blocker.block/unblock()
	if Game.world != null:  
		print("disable")
		Game.world.get_node("%MouseRaycast").disabled = true


func _on_mouse_exited() -> void:
	if Game.world != null:  
		print("disable")
		Game.world.get_node("%MouseRaycast").disabled = true


func _on_active_button_mouse_entered() -> void:
	if Game.world != null:  
		print("disable")
		Game.world.get_node("%MouseRaycast").disabled = true


func _on_active_button_mouse_exited() -> void:
	if Game.world != null: 
		Game.world.get_node("%MouseRaycast").disabled = false
