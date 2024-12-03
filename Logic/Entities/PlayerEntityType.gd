class_name PlayerEntityType extends EntityType

func create_base_object() -> CombatObject:
	var ent := PlayerEntity.new()
	ent.type = self
	ent.hp = max_hp
	ent.team = team
	return ent
