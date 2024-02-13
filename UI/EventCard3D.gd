class_name EventCard3D extends Node3D

var card_2d: EventCard2D

const EVENT_CARD_2D = preload("res://UI/EventCard2D.tscn")

func _enter_tree() -> void:
	$Quad.get_surface_override_material(0).albedo_texture = $Quad/SubViewport.get_texture()

func set_card(card: EventCard2D):
	card_2d = card
	$Quad/SubViewport.add_child(card)

func setup(event: SpellType, round_highlight := -1):
	set_card(EVENT_CARD_2D.instantiate())
	card_2d.set_event(event, round_highlight)
