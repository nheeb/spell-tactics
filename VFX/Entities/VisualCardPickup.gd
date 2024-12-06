extends VisualEntity

func set_spell_type(spell_type: SpellType):
	$Pivot1/Pivot2/Pivot3/HandCard3D.set_spell_type(spell_type)
	$AnimationPlayer.seek(randf_range(0.0, 7.9))
