class_name Spell extends Object

var type: SpellType
var combat: Combat
var logic: SpellLogic
var visual_representation: ControlNodeCard

var combat_persistant_properties := {}
var round_persistant_properties := {}

func _init(_type: SpellType, _combat : Combat = null) -> void:
	type = _type
	combat = _combat
	if combat != null:
		logic = type.logic.new(self)

func get_copy_for_combat(_combat: Combat) -> Spell:
	var spell := Spell.new(type, _combat)
	spell.combat_persistant_properties = combat_persistant_properties.duplicate()
	return spell

func serialize() -> SpellState:
	var state := SpellState.new()
	state.type = type
	state.combat_persistant_properties = combat_persistant_properties
	state.round_persistant_properties = round_persistant_properties
	return state
	
func _to_string() -> String:
	return type.internal_name
