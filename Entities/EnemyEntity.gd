@tool
class_name EnemyEntity extends HPEntity

var actions: Array[EnemyMove]
var movements: Array[EnemyMove]
#var passives: Array[Node]

## To implement things like stuns / combo attacks / ...
var forced_movement_name: String
var forced_action_name: String

enum Teams {
	Evil,
	Good,
}

var team := Teams.Evil

var agility: int = 0
var strength: int = 1
var accuracy: int = 0
var resistance: int = 0

signal regular_movement_done
signal regular_action_done

func do_movement() -> void:
	if forced_movement_name == "":
		do_random_move(movements)
		regular_movement_done.emit()
	else:
		do_forced_move(forced_movement_name)
		forced_movement_name = ""

func do_action() -> void:
	if forced_action_name == "":
		do_random_move(actions)
		regular_action_done.emit()
	else:
		do_forced_move(forced_action_name)
		forced_action_name = ""

func do_forced_move(move_name: String) -> void:
	var _move := EnemyMove.from_string(move_name, self)
	_move.forced = true
	_move.execute()
	_move.free()
	
func do_random_move(moveset: Array[EnemyMove]):
	var scores : Array[float] = []
	scores.append_array(moveset.map(func(x): return x.get_score()))
	var index := Utility.random_index_of_scores(scores)
	if index == -1:
		printerr("%s has no move to choose." % type.pretty_name)
	else:
		var selected_move : EnemyMove = moveset[index]
		combat.log.create_and_register_entry(get_name() + " does " + type.actions[index], LogEntry.Type.Enemy)
		selected_move.execute()
		

func on_create() -> void:
	super.on_create()
	type = type as EnemyEntityType
	actions.append_array(type.actions.map(func(s): return EnemyMove.from_string(s, self)))
	movements.append_array(type.movements.map(func(s): return EnemyMove.from_string(s, self)))
	actions = actions.filter(func(a): return a != null)
	movements = movements.filter(func(a): return a != null)

func on_death():
	super.on_death()
	combat.enemies.erase(self)

func sync_with_type() -> void:
	super()
	agility = type.agility
	strength = type.strength
	accuracy = type.accuracy
	resistance = type.resistance

func get_name() -> String:
	return "%s_%s" % [type.pretty_name, id.to_string()]
