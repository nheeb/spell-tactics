class_name CardTexture extends Control

@onready var icon_texture : CardIconTexture = $HandCardIconTexture

func set_castable_type(type: CastableType):
	$HandCardIconTexture.set_castable_type(type)
	$Container/GridContainer/CenterContainer/TitleLabel.text=type.pretty_name
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text=type.effect_text

func set_castable(castable: Castable):
	$HandCardIconTexture.set_castable_type(castable.type)
	$Container/GridContainer/CenterContainer/TitleLabel.text=castable.type.pretty_name
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text=castable.get_effect_text()

func set_error(text: String = ""):
	%ErrorLabel.text = text

func set_miniature_variant_energy_type(et: EnergyStack.EnergyType):
	$HandCardIconTexture.set_main_icon_texture(VFX.type_to_icon(et, true))
	$Container/GridContainer/CenterContainer/TitleLabel.text = ""
	$Container/GridContainer/CenterContainer2/SpellTextLabel.text = ""
