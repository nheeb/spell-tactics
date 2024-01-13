class_name ControlNodeCard extends Control

signal selected(spell: Spell)

var spell: Spell

func set_spell(_spell):
	spell = _spell
	if is_instance_valid(spell.visual_representation):
		printerr("Spell already has a visual representation Card")
	spell.visual_representation = self
	update()

func update():
	set_content(spell.type.pretty_name, Utility.energy_to_string(spell.logic.get_costs()), spell.type.effect_text, spell.type.fluff_text)

func set_content(pretty_name: String, costs: String, effect: String, fluff: String):
	%Name.text = pretty_name
	%Costs.text = costs
	%Effect.text = effect
	%Fluff.text = fluff

func _on_gui_input(event):
	if event.is_action("select"):
		selected.emit(spell)
