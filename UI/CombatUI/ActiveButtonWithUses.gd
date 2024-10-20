class_name ActiveButtonWithUses extends Control

const MAX_USES: int = 3
const ACTIVE_USE_BUBBLE = preload("res://UI/CombatUI/Actives/ActiveUseBubble.tscn")

@onready var button: TextureButton = $ActiveButton
@onready var bubbles: Array[ActiveUseBubble] = [$ActiveUseBubble1, $ActiveUseBubble2, $ActiveUseBubble3]
@onready var positions: Array[Marker2D] = [$Position1, $Position2, $Position3]
@onready var hotkey_label: Label = %HotkeyLabel

@export var grey_out_modulate: Color = Color("909090")

var combat: Combat

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
	elif get_tree().current_scene == self:
		# load debug active
		active = Active.new(ActiveType.load_from_file("res://Spells/AllActives/TestActive.tres"), null)
	else:
		push_warning("no active set on initializing ActiveButton")

func restart_bubbles():
	while not bubbles.is_empty():
		var bubble_to_delete = bubbles.pop_back()
		bubble_to_delete.free()

	var bubble: ActiveUseBubble
	for i in range(MAX_USES):
		bubble = ACTIVE_USE_BUBBLE.instantiate()
		bubble.name = "ActiveUseBubble%d" % (i+1)
		
		add_child(bubble)
		bubble.position = get_node("Position" + str(i+1)).position
		bubbles.append(bubble)


func init_active(new_active: Active): 
	button.icon.texture = new_active.type.icon
	hotkey_label.text = new_active.type.hotkey_label

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

			bubble1.position = $TwoBubblesPosition1.position
			bubble2.position = $TwoBubblesPosition2.position
		3:
			pass # do nothing
		_: 
			push_error("Active %s  max_uses = %d. weird, huh?" % [new_active.type.pretty_name, max_uses])


func grey_out():
	%ActiveButton.modulate = grey_out_modulate
	%ActiveButton.material.set_shader_parameter("grey_out_progress", 1.0)
	
	
func undo_grey_out():
	%ActiveButton.modulate = Color.WHITE
	%ActiveButton.material.set_shader_parameter("grey_out_progress", 0.0)
	

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
		
	if uses_left == 0:
		grey_out()
	else:
		undo_grey_out()
		

## TODO Idea: RayCast.register_new_blocker() -> blocker.block/unblock()

func _on_active_button_mouse_entered() -> void:
	if Game.world != null:  
		Game.world.get_node("%MouseRaycast").disabled = true


func _on_active_button_mouse_exited() -> void:
	if Game.world != null: 
		Game.world.get_node("%MouseRaycast").disabled = false


func _on_active_button_toggled(toggled_on: bool) -> void:
	var uses_left = active.get_limitation_uses_left()
	bubbles[uses_left - 1].highlighted = toggled_on
