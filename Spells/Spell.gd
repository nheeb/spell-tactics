class_name Spell extends Object

var type: SpellType
var id: SpellID
var combat: Combat
var logic: SpellLogic
var visual_representation: HandCard2D
var event_logic: EventSpellLogic:
	get:
		if not type.is_event_spell:
			printerr("Trying to get an EventSpellLogic from a non event spell")
		return logic as EventSpellLogic

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
	state.id = id
	state.combat_persistant_properties = combat_persistant_properties
	state.round_persistant_properties = round_persistant_properties
	return state
	
func _to_string() -> String:
	return type.internal_name

func get_reference() -> SpellReference:
	return SpellReference.new(self)
