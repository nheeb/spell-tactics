class_name HandCard3D extends Node3D

var card_2d: HandCard2D

func _enter_tree() -> void:
	$Quad.get_surface_override_material(0).albedo_texture = $Quad/SubViewport.get_texture()

func get_spell() -> Spell:
	var spell =  $Quad/SubViewport/HandCard2D.spell
	return spell

func set_card(card: HandCard2D):
	card_2d = card
	$Quad/SubViewport.add_child(card)
	
