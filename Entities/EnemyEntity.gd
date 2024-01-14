class_name EnemyEntity extends HPEntity

var actions: Array[EnemyMove]
var movements: Array[EnemyMove]
#var passives: Array[Node]

## To implement things like stuns / combo attacks / ...
var forced_movements: Array[EnemyMove]
var forced_actions: Array[EnemyMove]

func do_movement() -> void:
	do_move(movements, forced_movements)

func do_action() -> void:
	do_move(actions, forced_actions)

func do_move(moveset: Array[EnemyMove], forced_moveset: Array[EnemyMove]) -> void:
	# TODO use move.get_score(self) to decide on a move and execute it
	pass
