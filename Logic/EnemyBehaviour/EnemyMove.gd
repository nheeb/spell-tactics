class_name EnemyMove extends Node

## Abstract Class for Enemy Movements and Actions

## Returns a score for the attractiveness to do the move.
func get_score(enemy: EnemyEntity) -> float:
	return 0.0

## Executes the move
func execute(enemy: EnemyEntity) -> void:
	pass
