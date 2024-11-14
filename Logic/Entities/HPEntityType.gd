class_name HPEntityType extends EntityType

enum Teams {Evil, Neutral, Good}

@export var max_hp: int
@export var team := Teams.Evil

func create_base_object() -> CombatObject:
	var ent := HPEntity.new()
	ent.type = self
	ent.hp = max_hp
	ent.team = team
	return ent
