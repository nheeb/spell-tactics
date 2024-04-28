class_name Cards3D extends Node3D

const CAM_MODE_PERSPECTIVE = true
const CAM_MODE_ORTHOGONAL = not CAM_MODE_PERSPECTIVE
const CAM_PERSPECTIVE_DISTANCE = 16.0

signal card_selected(spell: Spell)

enum HandState {
	Closed,
	Open,
	Hover,
	Drag
}

static var OPEN_Y := -1.1 # Height of open hand cards
static var CLOSED_Y := -2.15 # Height of closed hand cards
static var OPEN_AT_NORM_MOUSE_POS = .3 # Open hand when mouse at normalized y pos
static var CLOSE_AT_NORM_MOUSE_POS = .48 # Close hand when mouse at normalized y pos
const BASE_ROTATION = Vector3(0.0, - PI / 2, 0.0)
const RADIAL_TURN = 1.0 # Rotate cards like in a real hand
const RADIAL_ORIGIN_Y = -5.0 # 
const PADDING = .9 # Distance between the cards
const CLOSED_PADDING_EXTRA = -.39 # Distance change when hand closed
static var HOVER_SCALE := 1.3 # Scale of hovered card
static var HOVER_PUSH := .2 # Push Distance of adjacent cards
static var HOVER_LIFT := 0.0 # Y lift of hovered card
static var DRAG_SCALE := 1.15
const DRAG_PUSH = .3 # Gap size when rearranging cards
const DRAG_ARRANGE_NORM_MOUSE_POS = .45
const Z_BASE = -2.0
#const Z_UNIT = .1
const BOW_HEIGHT = .15 # Bow shape of card hand
const PINNED_SCALE = 1.5
const PINNED_ROTATION = BASE_ROTATION + Vector3(PI / 12, - PI / 8, 0.0)
const HOVER_BALANCE_RAD = PI / 12
const HOVER_BALANCE_RANGE = .5
const HOVER_BALANCE_Y_BONUS = 1.5
const CHOSEN_LIFT = .5

var hand_state: HandState = HandState.Closed
var all_cards : Array[HandCard3D] = []
var hand_cards : Array[HandCard3D] = []
var hovered_card : HandCard3D = null
var dragged_card : HandCard3D = null
var dragged_on_hand := false
var dragged_before : HandCard3D = null
var drag_target_pos : Vector3
var pinned_card : HandCard3D = null
var mouse_pos_on_card_layer : Vector3

var test_mode := false # This is true when the scene runs solo

@onready var camera := %Camera3D
@onready var cards := %Cards

var combat: Combat

const HAND_CARD_2D = preload("res://UI/HandCard2D.tscn")
func _ready() -> void:
	# enable this once everything is set up
	#process_mode = Node.PROCESS_MODE_DISABLED
	# Add attributes to global settings
	DebugInfo.global_settings_config(self, "3D Cards")
	DebugInfo.global_settings_add("OPEN_Y", -3.0, 0.0)
	DebugInfo.global_settings_add("CLOSED_Y", -3.0, 0.0)
	DebugInfo.global_settings_add("HOVER_SCALE", .5, 2.0)
	DebugInfo.global_settings_add("HOVER_PUSH", 0.0, 1.0)
	DebugInfo.global_settings_add("HOVER_LIFT", -1.0, 1.0)
	DebugInfo.global_settings_add("DRAG_SCALE", .5, 2.0)
	DebugInfo.global_settings_add("OPEN_AT_NORM_MOUSE_POS", 0.0, 1.0)
	DebugInfo.global_settings_add("CLOSE_AT_NORM_MOUSE_POS", 0.0, 1.0)
	
	# Set cam mode
	camera.projection = Camera3D.PROJECTION_PERSPECTIVE if CAM_MODE_PERSPECTIVE \
			 else Camera3D.PROJECTION_ORTHOGONAL
	if CAM_MODE_PERSPECTIVE:
		camera.position.z = CAM_PERSPECTIVE_DISTANCE + Z_BASE
		camera.fov = 2 * rad_to_deg(atan(-Z_BASE/CAM_PERSPECTIVE_DISTANCE))
		#print(camera.fov)
		#print(camera.position.z)
		
	
	# Move cards z
	cards.global_position.z = Z_BASE
	
	# add dummy cards if debugging this scene alone
	if get_tree().current_scene.name == "Cards3D":
		test_mode = true
		for i in range(5):
			add_card(HAND_CARD_2D.instantiate())
			await get_tree().create_timer(.5).timeout

func setup(_combat : Combat):
	combat = _combat

const HAND_CARD = preload("res://UI/HandCard.tscn")
func add_card(card_2d: HandCard2D):
	var hand_card = HAND_CARD.instantiate()
	hand_card.set_card(card_2d)
	cards.add_child(hand_card)
	#hand_card.owner = self
	all_cards.append(hand_card)
	hand_cards.push_front(hand_card)
	hand_card.global_position = %CardSpawn.global_position
	hand_card.global_position.z = Z_BASE

const EVENT_CARD = preload("res://UI/EventCard3D.tscn")
const EVENT_HEIGHT = 2.0
var current_shown_event_card: EventCard3D
func show_event(event: SpellType, round_highlight := -1, speed_factor := 1.0) -> void:
	if is_event_currently_shown(event, round_highlight):
		return
	if current_shown_event_card:
		hide_event()
	var event_card = EVENT_CARD.instantiate()
	event_card.setup(event, round_highlight)
	%EventCards.add_child(event_card)
	event_card.position.y = EVENT_HEIGHT
	event_card.rotation_degrees.y = 180.0
	var tween := VisualTime.new_tween()
	tween.tween_property(event_card, "position:y", 0.0, 1.0 / speed_factor).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(event_card, "rotation_degrees:y", 0.0, 1.0 / speed_factor).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	current_shown_event_card = event_card

func is_event_currently_shown(event: SpellType, round_highlight := -1):
	if current_shown_event_card:
		if current_shown_event_card.card_2d.spell_type == event:
				return round_highlight == -1 or \
					   round_highlight == current_shown_event_card.card_2d.round_highlight
	return false

func hide_event() -> void:
	if current_shown_event_card:
		current_shown_event_card.queue_free()
		current_shown_event_card = null

func remove_card(card2d: HandCard2D):
	var to_be_removed : HandCard3D = null

	for card_3d in all_cards:
		if card_3d.card_2d.spell == card2d.spell:
			cards.remove_child(card_3d)
			to_be_removed = card_3d

	if not to_be_removed:
		printerr("Card ", card2d, " which should be removed not found.")
		return
	
	all_cards.erase(to_be_removed)
	hand_cards.erase(to_be_removed)
	hovered_card = null if hovered_card == to_be_removed else hovered_card
	dragged_card = null if dragged_card == to_be_removed else dragged_card
	pinned_card = null if pinned_card == to_be_removed else pinned_card

func _process(delta: float) -> void:
	check_hand_state()
	calc_positions()
	visual_process(VisualTime.visual_time_scale * delta)

var raycast_hit := false
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
	var cards_plane := Plane(Vector3.BACK,cards.global_position)
	
	var ray_layer_intersection = cards_plane.intersects_ray(ray_origin, ray_direction)
	var mouse_pos_3d : Vector3 = Vector3(0.0, 0.0, Z_BASE)
	if ray_layer_intersection:
		mouse_pos_3d = ray_layer_intersection
		mouse_pos_on_card_layer = mouse_pos_3d
	
	raycast_hit = false
	var card_on_cursor: HandCard3D = null
	if %MouseRayCast.is_colliding():
		var collider = %MouseRayCast.get_collider()
		if collider is Area3D and collider.is_in_group("hand_area"):
			card_on_cursor = collider.get_parent()
			raycast_hit = true
	
	match hand_state:
		HandState.Closed:
			if mouse_pos_2d_normalized.y < OPEN_AT_NORM_MOUSE_POS:
				hand_state = HandState.Open
		HandState.Open:
			if mouse_pos_2d_normalized.y > CLOSE_AT_NORM_MOUSE_POS:
				hand_state = HandState.Closed
			elif card_on_cursor:
				if card_on_cursor in hand_cards:
					_set_hovered_card(card_on_cursor)
					hand_state = HandState.Hover
		HandState.Hover:
			if not card_on_cursor:
				hand_state = HandState.Open
				_set_hovered_card(null)
			else:
				if hovered_card != card_on_cursor:
					_set_hovered_card(card_on_cursor)
				if Input.is_action_just_pressed("select"):
					if choice_running:
						choose_card(hovered_card)
					else:
						hand_state = HandState.Drag
						dragged_on_hand = true
						drag_target_pos = mouse_pos_3d
						dragged_card = card_on_cursor
						hovered_card = null
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
					.filter(func(c): return c.global_position.x > mouse_pos_3d.x)\
					.reduce(func(a, b): return a if a.global_position.x < b.global_position.x else b)
			if not Input.is_action_pressed("select"):
				hand_state = HandState.Open
				
				var card_got_played := false
				
				if not dragged_on_hand:
					# Player tried to play the card
					var combat_agrees = true
					if combat != null:
						if combat.current_phase != Combat.RoundPhase.Spell:
							combat_agrees = false
					if test_mode or (dragged_card.card_2d.enabled and combat_agrees):
						card_got_played = true
						get_viewport().set_input_as_handled()
						card_selected.emit(dragged_card.get_spell())
						if pinned_card:
							pinned_card.card_2d.set_hover(false)
							if dragged_before:
								hand_cards.insert(hand_cards.find(dragged_before), pinned_card)
							else:
								hand_cards.append(pinned_card)
						pinned_card = dragged_card
						dragged_card = null
				if not card_got_played:
					# Card got rearranged
					dragged_card.card_2d.set_hover(false)
					if dragged_before:
						hand_cards.insert(hand_cards.find(dragged_before), dragged_card)
					else:
						hand_cards.append(dragged_card)
					dragged_card = null

	if choice_running:
		if Input.is_action_just_pressed("deselect"):
			clear_chosen_cards()

	if pinned_card and Input.is_action_just_pressed("deselect"):
		pinned_card.card_2d.set_hover(false)
		hand_cards.push_back(pinned_card)
		pinned_card = null

func _set_hovered_card(card):
	if hovered_card != null:
		hovered_card.card_2d.set_hover(false)
	hovered_card = card
	if hovered_card != null:
		hovered_card.card_2d.set_hover(true)
	Events.card_hovered.emit(card)

func calc_positions():
	# Create blank 2D positions, scales (float) & rotations
	var positions := {}
	var scales := {}
	var rotations := {}
	for card in all_cards:
		positions[card] = Vector2.ZERO
		scales[card] = 1.0
		rotations[card] = BASE_ROTATION
	var hand_size := hand_cards.size()
	var middle_index : float = (hand_size - 1.0) / 2.0
	match hand_state:
		HandState.Closed:
			for i in range(hand_size):
				var card := hand_cards[i]
				var pos_index := i - middle_index
				positions[card] = Vector2(pos_index * \
					(PADDING + CLOSED_PADDING_EXTRA), CLOSED_Y)
				rotations[card].z += atan(positions[card].x / RADIAL_ORIGIN_Y) * RADIAL_TURN
				var pos_index_norm := pos_index / middle_index
				var bow_height := BOW_HEIGHT * Utility.clamp_map_pow(\
					abs(pos_index_norm), 0.0, 1.0, 1.0, 0.0, 2.0)
				positions[card].y += bow_height
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
			var balance_pos := mouse_pos_on_card_layer - hovered_card.global_position
			rotations[hovered_card] += Vector3(\
				clamp(-balance_pos.y / HOVER_BALANCE_RANGE,-1,1) * HOVER_BALANCE_RAD,\
				clamp(balance_pos.x / HOVER_BALANCE_RANGE,-1,1) * HOVER_BALANCE_RAD * HOVER_BALANCE_Y_BONUS ,\
				0.0 )
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
			positions[dragged_card] = Utility.vec3_discard_z(drag_target_pos)
			scales[dragged_card] = DRAG_SCALE
	if choice_running:
		for card in chosen_cards:
			positions[card] -= Vector2.UP * CHOSEN_LIFT

	if pinned_card:
		positions[pinned_card] = Utility.vec3_discard_z(%PinnedCard.global_position) 
		scales[pinned_card] = PINNED_SCALE
		rotations[pinned_card] = PINNED_ROTATION

	# Submit all transformations to the
	for card in all_cards:
		#card.smooth_movement.target_pos = Utility.vec_xy_to_vec3(positions[card],\
				#Z_BASE + (hand_cards.find(card) * Z_UNIT if card != hovered_card else 0.0))
		card.smooth_movement.target_pos = Utility.vec_xy_to_vec3(positions[card], Z_BASE)
		card.smooth_movement.target_scale = scales[card] * Vector3.ONE
		card.smooth_movement.target_rotation = rotations[card]
		
		# Set render prio
		card.set_render_prio(hand_cards.find(card) \
			+ 20 * int(card == hovered_card) \
			+ 30 * int(card == pinned_card) \
			+ 40 * int(card == dragged_card) )
		
		# Hover card bigger collision
		card.set_collision_scale(1.2 if card == hovered_card else 1.0)

func visual_process(delta: float) -> void:
	for card in all_cards:
		if card == dragged_card:
			card.smooth_movement.movement_process(delta, 10.0)
		elif card == pinned_card:
			card.smooth_movement.movement_process(delta, 4.0)
		else:
			card.smooth_movement.movement_process(delta, 2.0)


#################
## Card Choice ##
#################

var choice_running := false
var choice_count_min : int
var choice_count_max : int
var chosen_cards: Array

signal card_chosen(chosen_card_count: int)

func start_choice(_min: int, _max: int) -> void:
	choice_count_min = _min
	choice_count_max = _max
	chosen_cards = []
	choice_running = true

func end_choice_and_get_result() -> Array:
	var _chosen_spells = []
	for c in chosen_cards:
		c = c as HandCard3D
		_chosen_spells.append(c.card_2d.spell)
	chosen_cards = []
	choice_running = false
	return _chosen_spells

func unchoose_card(card: HandCard3D) -> void:
	if card in chosen_cards:
		chosen_cards.erase(card)
		card_chosen.emit(chosen_cards.size())
	card.card_2d.set_chosen(false)

func choose_card(card) -> void:
	if not card in chosen_cards:
		chosen_cards.append(card)
	
		if chosen_cards.size() > choice_count_max:
			unchoose_card(chosen_cards.pop_front())
	
		card_chosen.emit(chosen_cards.size())
		
		card.card_2d.set_chosen(true)

func clear_chosen_cards():
	for card in chosen_cards:
		unchoose_card(card)
