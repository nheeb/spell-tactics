class_name CardTexture extends Control

@onready var icon_texture : CardIconTexture = $HandCardIconTexture

func set_spell_type(type: SpellType):
	$HandCardIconTexture.set_castable_type(type)
	%TitleLabel.text=type.pretty_name
	%SpellTextLabel.text=type.effect_text

func set_castable(castable: Castable):
	$HandCardIconTexture.set_castable_type(castable.type)
	%TitleLabel.text=castable.type.pretty_name
	%SpellTextLabel.text=castable.get_effect_text()

func set_error(text: String = ""):
	%ErrorLabel.text = text
