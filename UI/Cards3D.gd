extends Node3D

signal card_selected(spell: Spell)

@onready var camera := %Camera3D

func _ready() -> void:
	pass # Replace with function body.


var number_of_cards = 0  # maybe read from combat instead, idk0
const HAND_CARD = preload("res://UI/HandCard.tscn")
func add_card(cnc: HandCard2D):
	number_of_cards += 1
	var hand_card = $CameraPivot/CardOrigin.get_node("HandCard" + str(number_of_cards))
	hand_card.set_card(cnc)



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
