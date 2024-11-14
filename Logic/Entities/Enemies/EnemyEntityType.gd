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
	var ent: EnemyEntity = EnemyEntity.new()
	ent.type = self
	ent.hp = max_hp
	ent.agility = agility
	ent.strength = strength
	ent.accuracy = accuracy
	ent.resistance = resistance
	ent.movement_range = movement_range
	return ent
