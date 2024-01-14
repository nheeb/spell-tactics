class_name Spell extends Object

var type: SpellType
var logic: SpellLogic
var visual_representation: ControlNodeCard

func _init(_type: SpellType) -> void:
	type = _type
	logic = type.logic.new()
	
