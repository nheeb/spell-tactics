class_name SpellType extends CastableType

func create_base_object() -> CombatObject:
	var spell := Spell.new()
	spell.type = self
	return spell
