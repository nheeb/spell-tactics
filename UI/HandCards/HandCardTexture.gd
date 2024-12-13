class_name CardTexture extends Control

@onready var icon_texture: CardIconTexture = $HandCardIconTexture
@onready var title_label: Label = %TitleLabel
@onready var spell_text_label: Label = %SpellTextLabel

func _ready() -> void:
	pass

func set_spell_text(text: String):
	spell_text_label.text = text
	await VisualTime.visual_process
	var first_with_3_lines := 0 
	while spell_text_label.get_visible_line_count() > 2 \
		and spell_text_label.label_settings.font_size > 26:
			if first_with_3_lines == 0:
				if spell_text_label.get_visible_line_count() <= 3:
					first_with_3_lines = spell_text_label.label_settings.font_size
			spell_text_label.label_settings.font_size -= 2
			await VisualTime.visual_process
	if spell_text_label.get_visible_line_count() > 2:
		if first_with_3_lines != 0:
			spell_text_label.label_settings.font_size = first_with_3_lines

func set_castable_type(type: CastableType):
	icon_texture.set_castable_type(type)
	title_label.text=type.pretty_name
	set_spell_text(type.effect_text)

func set_castable(castable: Castable):
	icon_texture.set_castable_type(castable.type)
	title_label.text=castable.type.pretty_name
	set_spell_text(castable.get_effect_text())

func set_error(text: String = ""):
	%ErrorLabel.text = text

func set_miniature_variant_energy_type(et: EnergyStack.EnergyType):
	icon_texture.set_main_icon_texture(VFX.type_to_icon(et, true))
	title_label.text = ""
	spell_text_label.text = ""
