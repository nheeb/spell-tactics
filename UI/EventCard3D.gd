class_name EventCard3D extends Node3D

var card_2d: EventCard2D

func _enter_tree() -> void:
	$Quad.get_surface_override_material(0).albedo_texture = $Quad/SubViewport.get_texture()

func set_card(card: EventCard2D):
	card_2d = card
	$Quad/SubViewport.add_child(card)

func setup(event: SpellType, round_highlight := -1):
	pass
