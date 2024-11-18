class_name EnemyEntityType extends HPEntityType

@export var behaviour: EnemyBehaviour
@export var actions: Array[EnemyActionArgs]

@export_group("Traits")
@export var agility: int = 0
@export var strength: int = 1
@export var accuracy: int = 0
@export var resistance: int = 0
@export var movement_range: int = 2

func create_base_object() -> CombatObject:
	return EnemyEntity.new()

func set_type_properties(object: CombatObject) -> void:
	super(object)
	object.agility = agility
	object.strength = strength
	object.accuracy = accuracy
	object.resistance = resistance
	object.movement_range = movement_range
