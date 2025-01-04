class_name CardTexture extends Control

@onready var icon_texture: CardIconTexture = %HandCardIconTexture
@onready var title_label = %TitleLabel
@onready var spell_text_label: SpellTextLabel = %SpellTextLabel

func _ready() -> void:
	# need to call this explicitly to load onready vars ?!
	pass

func set_castable_type(type: CastableType):
	set_color(type.color)
	icon_texture.set_castable_type(type)
	title_label.text="[center]" + type.pretty_name + "[/center]"
	while title_label.get_line_count() > 1:
		title_label.set("theme_override_font_sizes/normal_font_size", 
						title_label.get("theme_override_font_sizes/normal_font_size") - 2)
	spell_text_label.set_spell_text(type.effect_text)

func set_castable(castable: Castable):
	set_color(castable.type.color)
	icon_texture.set_castable_type(castable.type)
	title_label.text="[center]" + castable.type.pretty_name + "[/center]"
	spell_text_label.set_spell_text(castable.get_effect_text())

	
func set_color(color: Color):
	%TitleLabel.set("theme_override_colors/default_color", color)
	%HandCardIconTexture.modulate = color
	

func set_miniature_variant_energy_type(et: EnergyStack.EnergyType):
	icon_texture.set_main_icon_texture(VFX.type_to_icon(et, true))
	set_color(VFX.type_to_color(et))
	title_label.text = ""
	spell_text_label.text = ""
