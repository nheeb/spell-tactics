extends Node3D

signal card_selected(spell: Spell)

@onready var camera := %Camera3D
@onready var cards := %Cards

@export var card_gap = 0.06

const HAND_CARD = preload("res://UI/HandCard.tscn")
func add_card(card_2d: HandCard2D):
	
	var hand_card = HAND_CARD.instantiate()
	hand_card.set_card(card_2d)
	cards.add_child(hand_card)
	var n = cards.get_child_count()
	#print("n = %d, offset = %d" % [n, calc_offset(n)])
	#hand_card.position.x = calc_x_offset(n, n)
	update_all_x_offsets()
	

func calc_x_offset(i, n):
	# card width + gap
	var dist = 1.0 + card_gap
	var start = -(n-1) * dist / 2.0
	var step = i * dist
	var offset = start + step
	print("i=%d, n=%d, start=%f, offset=%f" % [i, n, start, offset])
	return offset
	
func update_all_x_offsets():
	var i = 0
	var n = cards.get_child_count()
	for hand_card in cards.get_children():
		hand_card.position.x = calc_x_offset(i, n)
		i += 1


func remove_card(card2d: HandCard2D):
	var removed = false
	var i = 0
	
	print("removing, ", card2d.spell)
	print()
	
	for card_3d in cards.get_children():
		if card_3d.card_2d.spell == card2d.spell:
			print("remove at i = %d" % i)
			cards.remove_child(card_3d)
			removed = true
		i += 1
	if not removed:
		printerr("Card ", card2d, " which should be removed not found.")
		return
	
	update_all_x_offsets()
	
	

var currently_hovering: HandCard2D = null
func _process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3 = camera.project_ray_normal(mouse_position)
	var end: Vector3 = ray_origin + ray_direction * 100
	
	%MouseRayCast.target_position = to_local(end)
	
	if %MouseRayCast.is_colliding():
		var collider = %MouseRayCast.get_collider()
		if collider is Area3D and collider.is_in_group("hand_area"):
			var hand_card = collider.get_parent()
			if currently_hovering != null:
				currently_hovering.set_hover(false)
			hand_card.card_2d.set_hover(true)
			currently_hovering = hand_card.card_2d
			if Input.is_action_just_pressed("select"):
			
				card_selected.emit(hand_card.get_spell())
	else:
		if currently_hovering != null:
			currently_hovering.set_hover(false)
			currently_hovering = null
