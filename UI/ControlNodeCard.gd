class_name ControlNodeCard extends Control

signal selected(spell: Spell)

var spell: Spell

func set_spell(_spell, as_hand_card := true):
	spell = _spell
	
	if as_hand_card:
		if is_instance_valid(spell.visual_representation):
			printerr("Spell already has a visual representation Card")
		spell.visual_representation = self
	else:
		%SelectButton.hide()
	
	update()

func update():
	set_content(spell.type.pretty_name, Utility.energy_to_string(spell.logic.get_costs()), spell.type.effect_text, spell.type.fluff_text)

func set_content(pretty_name: String, costs: String, effect: String, fluff: String):
	%Name.text = pretty_name
	%Costs.text = costs
	%Effect.text = effect
	# could always extend the fluff to 3 lines for consistent look
	%Fluff.text = fluff


func _on_button_button_down() -> void:
	selected.emit(spell)
	print("select")
