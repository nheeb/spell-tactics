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
	return Spell.new(type, _combat)
