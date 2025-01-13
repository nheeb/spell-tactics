class_name EnemyEntityType extends EntityType

@export var behaviour: EnemyBehaviour
@export var actions: Array[EnemyActionTemplate]

@export var gain_drain_on_kill := true

@export_group("Traits")
@export var agility: int = 0
@export var strength: int = 1
@export var accuracy: int = 0
@export var resistance: int = 0
@export var movement_range: int = 3

func create_base_object() -> CombatObject:
	return EnemyEntity.new()

func set_type_properties(object: CombatObject) -> void:
	super(object)
	object.agility = agility
	object.strength = strength
	object.accuracy = accuracy
	object.resistance = resistance
	object.movement_range = movement_range
