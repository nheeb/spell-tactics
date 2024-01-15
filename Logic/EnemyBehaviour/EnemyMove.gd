class_name EnemyMove extends Node

## Abstract Class for Enemy Movements and Actions

## Returns a score for the attractiveness to do the move.
func get_score(combat: Combat, enemy: EnemyEntity) -> float:
	return 0.0

## Executes the move
func execute(combat: Combat, enemy: EnemyEntity) -> void:
	pass
