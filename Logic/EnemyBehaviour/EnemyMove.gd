class_name EnemyMove extends Object

## Abstract Class for Enemy Movements and Actions

var combat: Combat
var enemy: EnemyEntity

func _init(_combat: Combat, _enemy: EnemyEntity) -> void:
	combat = _combat
	enemy = _enemy

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 0.0

## Executes the move
func execute() -> void:
	pass
