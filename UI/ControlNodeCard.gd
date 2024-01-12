class_name ControlNodeCard extends Control

signal selected(spell: Spell)

var spell: Spell

var energy_to_letter := {
	Game.Energy.Life: "L",
	Game.Energy.Decay: "D",
	Game.Energy.Stone: "S",
	Game.Energy.Water: "W",
	Game.Energy.Flow: "F",
	Game.Energy.Any: "X",
}

func set_spell(_spell):
	spell = _spell
	var cost_string = spell.type.costs.reduce(func(x, y): return x + energy_to_letter[y], "")
	set_content(spell.type.pretty_name, cost_string, spell.type.effect_text, spell.type.fluff_text)

func set_content(name: String, costs: String, effect: String, fluff: String):
	%Name.text = name
	%Costs.text = costs
	%Effect.text = effect
	%Fluff.text = fluff
	

func _on_gui_input(event):
	if event.is_action("select"):
		selected.emit(spell)
