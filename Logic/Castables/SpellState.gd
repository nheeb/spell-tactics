class_name SpellState extends CombatObjectState

@export var type: SpellType
@export var data := {}

func deserialize(combat: Combat = null) -> Spell:
	var spell : Spell = Spell.new(type, combat)
	spell.data = data
	spell.id = id
	return spell
