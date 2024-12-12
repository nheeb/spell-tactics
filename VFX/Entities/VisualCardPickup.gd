extends VisualEntity

@onready var card := %HandCard3D

func set_spell_type(spell_type: SpellType):
	var energy_type := spell_type.get_main_energy()
	card.set_miniature_variant_energy_type(energy_type)
	$AnimationPlayer.seek(randf_range(0.0, 7.9))
