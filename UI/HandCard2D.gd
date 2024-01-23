class_name HandCard2D extends Control

signal selected(spell: Spell)

var spell: Spell

func set_spell(_spell, as_hand_card := true):
	spell = _spell
	
	if as_hand_card:
		if is_instance_valid(spell.visual_representation):
			printerr("Spell already has a visual representation Card")
		spell.visual_representation = self

	update()

func update():
	set_content(spell.type.pretty_name, spell.logic.get_costs(), spell.type.effect_text, spell.type.fluff_text)

const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
@export var icon_size := 48
func set_content(pretty_name: String, costs: EnergyStack, effect: String, fluff: String):
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
func set_hover(hover: bool):
	if hover:
		$PanelContainer.set("theme_override_styles/panel", PANEL_HOVER)
	else:
		$PanelContainer.set("theme_override_styles/panel", PANEL_DEFAULT)


func _on_button_button_down() -> void:
	selected.emit(spell)
