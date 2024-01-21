class_name SpellState extends Resource

@export var type: SpellType
@export var id: SpellID
@export var combat_persistant_properties := {}
@export var round_persistant_properties := {}

func deserialize(combat: Combat = null) -> Spell:
	var spell : Spell = Spell.new(type, combat)
	spell.combat_persistant_properties = combat_persistant_properties
	spell.round_persistant_properties = round_persistant_properties
	spell.id = id
	return spell
