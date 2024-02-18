class_name EnemyMove extends Object

## Abstract Class for Enemy Movements and Actions

var combat: Combat
var enemy: EnemyEntity

var forced := false

func _init(_combat: Combat, _enemy: EnemyEntity) -> void:
	combat = _combat
	enemy = _enemy

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	return 0.0

## Executes the move
func execute() -> void:
	pass

static func from_string(s: String, e: EnemyEntity) -> EnemyMove:
	var script = load("res://Entities/Enemies/Moves/%s.gd" % s)
	if script:
		return script.new(e.combat, e)
	else:
		return null
