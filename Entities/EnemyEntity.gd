@tool
class_name EnemyEntity extends HPEntity

var actions: Array[EnemyMove]
var movements: Array[EnemyMove]
#var passives: Array[Node]

## To implement things like stuns / combo attacks / ...
#var forced_movements: Array[EnemyMove]
#var forced_actions: Array[EnemyMove]

enum Teams {
	Evil,
	Good,
}

var team := Teams.Evil

var agility: int = 0
var strength: int = 1
var accuracy: int = 0
var resistance: int = 0

func do_movement() -> void:
	do_move(movements)

func do_action() -> void:
	do_move(actions)

func do_move(moveset: Array[EnemyMove], forced_moveset: Array[EnemyMove] = []) -> void:
	# TODO use move.get_score(self) to decide on a move and execute it
	if forced_moveset.is_empty():
		var scores : Array[float] = []
		scores.append_array(moveset.map(func(x): return x.get_score()))
		var index := Utility.random_index_of_scores(scores)
		if index == -1:
			printerr("%s has no move to choose." % type.pretty_name)
		else:
			var selected_move : EnemyMove = moveset[index]
			selected_move.execute()
	else:
		for forced_move in forced_moveset:
			forced_move.execute()

func on_create() -> void:
	super.on_create()
	type = type as EnemyEntityType
	actions.append_array(type.actions.map(func(s): return EnemyMove.from_string(s, self)))
	movements.append_array(type.movements.map(func(s): return EnemyMove.from_string(s, self)))

func on_death():
	super.on_death()
	combat.enemies.erase(self)
