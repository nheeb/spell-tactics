class_name Cards3D extends Node3D

const CAM_MODE_PERSPECTIVE = false
const CAM_MODE_ORTHOGONAL = not CAM_MODE_PERSPECTIVE

signal card_selected(spell: Spell)

@onready var camera := %Camera3D
@onready var cards := %Cards

@export var card_gap = 0.06

var combat: Combat

const HAND_CARD_2D = preload("res://UI/HandCard2D.tscn")
func _ready() -> void:
	# Set cam mode
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE if CAM_MODE_PERSPECTIVE \
			 else Camera3D.PROJECTION_ORTHOGONAL
	
	# add dummy cards if debugging this scene alone
	if get_tree().current_scene.name == "Cards3D":
		for i in range(5):
			add_card(HAND_CARD_2D.instantiate())

const HAND_CARD = preload("res://UI/HandCard.tscn")
func add_card(card_2d: HandCard2D):
	var hand_card = HAND_CARD.instantiate()
	hand_card.set_card(card_2d)
	cards.add_child(hand_card)
	hand_card.owner = self
	var n = cards.get_child_count()
	#print("n = %d, offset = %d" % [n, calc_offset(n)])
	#hand_card.position.x = calc_x_offset(n, n)
	update_all_x_offsets()

const EVENT_CARD = preload("res://UI/EventCard3D.tscn")
const EVENT_HEIGHT = 2.0
var current_shown_event_card: EventCard3D
func show_event(event: SpellType, round_highlight := -1) -> void:
	var event_card = EVENT_CARD.instantiate()
	event_card.setup(event, round_highlight)
	%EventCards.add_child(event_card)
	event_card.position.y = EVENT_HEIGHT
	event_card.rotation_degrees.y = 180.0
	var tween := VisualTime.new_tween()
	tween.tween_property(event_card, "position:y", 0.0, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(event_card, "rotation_degrees:y", 0.0, 1.2).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	current_shown_event_card = event_card

func hide_event() -> void:
	if current_shown_event_card:
		current_shown_event_card.queue_free()
		current_shown_event_card = null

func calc_x_offset(i, n):
	# card width + gap
	var dist = 1.0 + card_gap
	var start = -(n-1) * dist / 2.0
	var step = i * dist
	var offset = start + step
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

	for card_3d in cards.get_children():
		if card_3d.card_2d.spell == card2d.spell:
			#print("remove at i = %d" % i)
			cards.remove_child(card_3d)
			removed = true
		i += 1
	if not removed:
		printerr("Card ", card2d, " which should be removed not found.")
		return
	
	update_all_x_offsets()
	

var currently_hovering: HandCard2D = null
var raycast_hit: bool = false
func _process(delta: float) -> void:
	var mouse_position := get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_position)
	var ray_direction: Vector3
	if CAM_MODE_ORTHOGONAL:
		ray_direction = Vector3.FORWARD
	else:
		ray_direction = camera.project_ray_normal(mouse_position)
	var ray_end: Vector3 = ray_origin + ray_direction * 50.0
	
	%MouseRayCast.global_position = ray_origin
	%MouseRayCast.target_position = %MouseRayCast.to_local(ray_end)
	
	# 3D Mouse pos on cards layer
	var ray_layer_intersection : Vector3 = Plane(cards.global_position, Vector3.FORWARD)\
								.intersects_ray(ray_origin, ray_direction)
	
	if %MouseRayCast.is_colliding():
		# this bool might need replacing with colision check on a wider area later on.
		# as it stands, the player can accidentally click on a tile through the gap between cards.
		raycast_hit = true
		
		var collider = %MouseRayCast.get_collider()
		if collider is Area3D and collider.is_in_group("hand_area"):
			var hand_card = collider.get_parent()
			var i = 0  # remove me
			for card in cards.get_children():
				i += 1
			if currently_hovering != null:
				currently_hovering.set_hover(false)
			hand_card.card_2d.set_hover(true)
			currently_hovering = hand_card.card_2d
			if Input.is_action_just_pressed("select"):
				var combat_agrees = true
				if combat != null:
					if combat.current_phase != Combat.RoundPhase.Spell:
						combat_agrees = false
				if hand_card.card_2d.enabled and combat_agrees:
					get_viewport().set_input_as_handled()
					card_selected.emit(hand_card.get_spell())
	else:
		if currently_hovering != null:
			currently_hovering.set_hover(false)
			currently_hovering = null
			
		raycast_hit = false



enum HandState {
	Closed,
	Open,
	Hover,
	Drag
}
var hand_state: HandState = HandState.Closed

var all_cards : Array[HandCard3D] = []
var hand_cards : Array[HandCard3D] = []
var hovered_card : HandCard3D = null
var dragged_card : HandCard3D = null
var dragged_on_hand := false
var dragged_before : HandCard3D = null
var drag_target_pos : Vector3

const OPEN_Y = 0.0 # Height of open hand cards
const CLOSED_Y = -0.7 # Height of closed hand cards
const OPEN_AT_NORM_MOUSE_POS = .2 # Open hand when mouse at normalized y pos
const CLOSE_AT_NORM_MOUSE_POS = .6 # Close hand when mouse at normalized y pos
const RADIAL_TURN = true # Rotate cards like in a real hand
const RADIAL_ORIGIN_Y = .1 # 
const PADDING = 1.0 # Distance between the cards
const CLOSED_PADDING_EXTRA = -.3 # Distance change when hand closed
const HOVER_SCALE = 1.4 # Scale of hovered card
const HOVER_PUSH = .5 # Push Distance of adjacent cards
const HOVER_LIFT = .4 # Y lift of hovered card
const DRAG_PUSH = .4 # Gap size when rearranging cards
const DRAG_ARRANGE_NORM_MOUSE_POS = .35
#const Z_UNIT = .1 
const BOW_HEIGHT = .2 # Bow shape of card hand


func check_hand_state():
	var mouse_pos_2d := Utility.get_mouse_pos_absolute()
	var mouse_pos_2d_normalized := Utility.get_mouse_pos_normalized()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos_2d)
	var ray_direction: Vector3
	if CAM_MODE_ORTHOGONAL:
		ray_direction = Vector3.FORWARD
	else:
		ray_direction = camera.project_ray_normal(mouse_pos_2d)
	var ray_end: Vector3 = ray_origin + ray_direction * 50.0
	
	%MouseRayCast.global_position = ray_origin
	%MouseRayCast.target_position = %MouseRayCast.to_local(ray_end)
	%MouseRayCast.force_raycast_update()
	
	# 3D Mouse pos on cards layer
	var ray_layer_intersection : Vector3 = Plane(cards.global_position, Vector3.FORWARD)\
								.intersects_ray(ray_origin, ray_direction)
	var mouse_pos_3d : Vector3 = ray_layer_intersection
	
	var card_on_cursor: HandCard3D = null
	if %MouseRayCast.is_colliding():
		var collider = %MouseRayCast.get_collider()
		if collider is Area3D and collider.is_in_group("hand_area"):
			card_on_cursor = collider.get_parent()
	
	match hand_state:
		HandState.Closed:
			if mouse_pos_2d_normalized.y < OPEN_AT_NORM_MOUSE_POS:
				hand_state = HandState.Open
		HandState.Open:
			if mouse_pos_2d_normalized.y > CLOSE_AT_NORM_MOUSE_POS:
				hand_state = HandState.Closed
			elif card_on_cursor:
				hovered_card = card_on_cursor
				hand_state = HandState.Hover
		HandState.Hover:
			if not card_on_cursor:
				hand_state = HandState.Open
			else:
				hovered_card = card_on_cursor
				if Input.is_action_just_pressed("select"):
					hand_state = HandState.Drag
					dragged_on_hand = true
					drag_target_pos = mouse_pos_3d
					dragged_card = card_on_cursor
					var drag_card_index := hand_cards.find(dragged_card)
					assert(drag_card_index != -1)
					if drag_card_index != hand_cards.size() - 1:
						dragged_before = hand_cards[drag_card_index + 1]
					else:
						dragged_before = null
					hand_cards.erase(dragged_card)
		HandState.Drag:
			drag_target_pos = mouse_pos_3d
			dragged_on_hand = mouse_pos_2d_normalized.y < DRAG_ARRANGE_NORM_MOUSE_POS
			if dragged_on_hand:
				dragged_before = hand_cards\
					.filter(func(c): return c.global_position.x > dragged_card.global_position.x)\
					.reduce(func(a, b): return a if a.global_position.x < b.global_position.x else b)
			if not Input.is_action_pressed("select"):
				hand_state = HandState.Open
				if dragged_before:
					hand_cards.insert(hand_cards.find(dragged_before), dragged_card)
				else:
					hand_cards.append(dragged_card)

func calc_positions():
	# Create blank 2D positions, scales (float) & rotations
	var positions := {}
	var scales := {}
	var rotations := {}
	for card in all_cards:
		positions[card] = Vector2.ZERO
		scales[card] = 1.0
		rotations[card] = 0.0
	var hand_size := hand_cards.size()
	var middle_index := (hand_size - 1.0) / 2.0
	match hand_state:
		HandState.Closed:
			for i in range(hand_size):
				var card := hand_cards[i]
				var pos_index := i - middle_index
				positions[card] = Vector2(pos_index * \
					(PADDING + CLOSED_PADDING_EXTRA), CLOSED_Y)
		HandState.Open:
			for i in range(hand_size):
				var card := hand_cards[i]
				var pos_index := i - middle_index
				positions[card] = Vector2(pos_index * PADDING, OPEN_Y)
		HandState.Hover:
			var hover_push := -HOVER_PUSH
			for i in range(hand_size):
				var card := hand_cards[i]
				var pos_index := i - middle_index
				if card == hovered_card:
					positions[card] = Vector2(pos_index * PADDING, OPEN_Y + HOVER_LIFT)
					scales[card] = HOVER_SCALE
					hover_push *= -1
				else:
					positions[card] = Vector2(pos_index * \
					PADDING + hover_push, OPEN_Y)
		HandState.Drag:
			if dragged_on_hand:
				var drag_push := -DRAG_PUSH
				for i in range(hand_size):
					var card := hand_cards[i]
					var pos_index := i - middle_index
					if card == dragged_before:
						drag_push *= -1
					positions[card] = Vector2(pos_index * PADDING + drag_push, OPEN_Y)
			else:
				for i in range(hand_size):
					var card := hand_cards[i]
					var pos_index := i - middle_index
					positions[card] = Vector2(pos_index * PADDING, OPEN_Y)
			positions[dragged_card] = drag_target_pos

	for card in all_cards:
		card.smooth_movement.target_pos = positions[card]
		card.smooth_movement.target_scale = scales[card]

func visual_process(delta: float) -> void:
	for card in all_cards:
		card.smooth_movement.movement_process(delta)
