extends Control

func set_spell_type(type: SpellType):
	$HandCardIconTexture.set_spell_type(type)
	$Container/GridContainer/CenterContainer/TitleLabel.text=type.pretty_name
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text=type.effect_text
