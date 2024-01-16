class_name EnemyEntityType extends HPEntityType

enum Behaviour {
	Fighter,
	Archer,
	Support
}

@export var behaviour: Behaviour
@export var agility: int
@export var actions: Array[String]
@export var movements: Array[String]
@export var passives: Array[String]
