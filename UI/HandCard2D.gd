class_name HandCard2D extends Control

signal selected(spell: Spell)

var spell: Spell
var spell_type: SpellType

func set_spell(_spell, as_hand_card := true):
	spell = _spell
	if as_hand_card:
		if is_instance_valid(spell.visual_representation):
			printerr("Spell already has a visual representation Card")
		spell.visual_representation = self
	update()

func set_spell_type(_spell_type):
	spell_type = _spell_type
	spell = null
	%Name.label_settings.font_size = 24
	%Fluff.label_settings.font_size = 16
	%Effect.label_settings.font_size = 16
	update()

func update():
	if spell != null:
		set_content(spell.type.pretty_name, spell.logic.get_costs(), spell.type.effect_text, spell.type.fluff_text)
	elif spell_type:
		set_content(spell_type.pretty_name, spell_type.costs, spell_type.effect_text, spell_type.fluff_text)

const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
const SHRINKED_TITLE = preload("res://Assets/Fonts/LabelSettings/HandCard2D_Title_LabelSettings_shrinked.tres")
@export var icon_size := 56
func set_content(pretty_name: String, costs: EnergyStack, effect: String, fluff: String):
	if len(pretty_name) > 15:
		%Name.label_settings = SHRINKED_TITLE
	%Name.text = pretty_name
	%Effect.text = effect
	for cost in costs.stack:
		var icon = ENERGY_ICON.instantiate()
		icon.type = cost
		icon.min_size = icon_size
		%EnergyContainer.add_child(icon)

	# could always extend the fluff to 3 lines for consistent look
	%Fluff.text = fluff
	

const PANEL_DEFAULT = preload("res://UI/Theme/HandCard2D_panel_default.tres")
const PANEL_HOVER = preload("res://UI/Theme/HandCard2D_panel_hover.tres")
const PANEL_DISABLED = preload("res://UI/Theme/HandCard2D_panel_disabled.tres")

var hovered: bool
var enabled: bool

func set_hover(hover: bool):
	if enabled:
		if hover:
			$PanelContainer.set("theme_override_styles/panel", PANEL_HOVER)
		else:
			$PanelContainer.set("theme_override_styles/panel", PANEL_DEFAULT)
		
		
func set_enabled(e: bool):
	enabled = e
	if e:
		$PanelContainer.set("theme_override_styles/panel", PANEL_DEFAULT)
	else:
		$PanelContainer.set("theme_override_styles/panel", PANEL_DISABLED)
		


func _on_button_button_down() -> void:
	selected.emit(spell)
