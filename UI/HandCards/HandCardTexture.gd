extends Control

func set_spell_type(type: SpellType):
	$HandCardIconTexture.set_castable_type(type)
	$Container/GridContainer/CenterContainer/TitleLabel.text=type.pretty_name
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text=type.effect_text

func set_castable(castable: Castable):
	$HandCardIconTexture.set_castable_type(castable.type)
	$Container/GridContainer/CenterContainer/TitleLabel.text=castable.type.pretty_name
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text=castable.get_effect_text()

func set_error(text: String = ""):
	%ErrorLabel.text = text
