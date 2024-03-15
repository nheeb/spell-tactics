class_name HandCard2D extends Control

signal selected(spell: Spell)
signal pressed(card: HandCard2D)

var spell: Spell
var spell_type: SpellType
var spell_state: SpellState

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
	%Name.label_settings.font_size = 28
	%Fluff.label_settings.font_size = 16
	%Effect.label_settings.font_size = 24
	%EnergyContainer.custom_minimum_size = Vector2(0, 8)
	%EnergyContainer.minimum_size_changed.emit()
	for icon in %EnergyContainer.get_children():
		icon.min_size = 12
		icon.minimum_size_changed.emit()
	update()

# Used by out of combat UI.
func set_spell_state(_spell_state):
	spell_state = _spell_state

func update():
	if spell != null:
		set_content(spell.type.pretty_name, spell.logic.get_costs(), spell.get_effect_text(), spell.type.fluff_text)
	elif spell_type:
		set_content(spell_type.pretty_name, spell_type.costs, spell_type.get_effect_text(), spell_type.fluff_text, true)

const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
const SHRINKED_TITLE = preload("res://Assets/Fonts/LabelSettings/HandCard2D_Title_LabelSettings_shrinked.tres")
@export var icon_size := 56
@export var icon_size_spelltype := 32
func set_content(pretty_name: String, costs: EnergyStack, effect: String, fluff: String, _spell_type: bool = false):
	if len(pretty_name) > 15 and not _spell_type:
		%Name.label_settings = SHRINKED_TITLE
	%Name.text = pretty_name
	%Effect.text = effect
	for cost in costs.stack:
		var icon = ENERGY_ICON.instantiate()
		icon.type = cost
		if _spell_type:
			icon.min_size = icon_size_spelltype
		else:
			icon.min_size = icon_size
		%EnergyContainer.add_child(icon)

	# could always extend the fluff to 3 lines for consistent look
	%Fluff.text = fluff
	

const PANEL_DEFAULT = preload("res://UI/Theme/HandCard2D_panel_default.tres")
const PANEL_HOVER = preload("res://UI/Theme/HandCard2D_panel_hover.tres")
const PANEL_DISABLED = preload("res://UI/Theme/HandCard2D_panel_disabled.tres")
const PANEL_CHOSEN = preload("res://UI/Theme/HandCard2D_panel_chosen.tres")
const PANEL_PRIORITY_ORDER = [PANEL_CHOSEN, PANEL_DISABLED, PANEL_HOVER, PANEL_DEFAULT]

var panel_stack = [PANEL_DEFAULT]

func set_panel(panel, b: bool = not (panel in panel_stack)):
	if b != (panel in panel_stack):
		if b:
			panel_stack.append(panel)
		else:
			panel_stack.erase(panel)
		
		panel_stack.sort_custom(func(x, y): return PANEL_PRIORITY_ORDER.find(x) < PANEL_PRIORITY_ORDER.find(y))

		$PanelContainer.set("theme_override_styles/panel", panel_stack[0])

func set_chosen(c: bool):
	set_panel(PANEL_CHOSEN, c)

func set_hover(hover: bool):
	set_panel(PANEL_HOVER, hover)

func set_enabled(e: bool):
	set_panel(PANEL_DISABLED, not e)

var _last_pressed_state: bool = false

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit(self)

func _on_button_button_down() -> void:
	selected.emit(spell)
