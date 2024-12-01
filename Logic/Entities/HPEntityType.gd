class_name HPEntityType extends EntityType

enum Teams {Evil, Neutral, Good}

@export var max_hp: int
@export var team := Teams.Evil

func create_base_object() -> CombatObject:
	return HPEntity.new()

func set_type_properties(object: CombatObject) -> void:
	super(object)
	object.hp = max_hp
	object.team = team
