class_name PAQuickCast extends PlayerAction

var castable: Castable
var targets: Array[Tile] = []

func _init(_castable: Castable, _targets: Array[Tile] = []) -> void:
	castable = _castable
	targets = _targets
	action_string = "Quick Cast <%s> on [%s]" % [castable, targets]

func is_valid(combat: Combat) -> bool:
	if not castable is Active:
		push_error("Quick cast for spells / other is not implemented.")
		return false
	castable.create_details(combat.player)
	castable.add_target_to_details(targets)
	var valid := castable.is_selectable() and castable.is_castable()
	castable.reset_details()
	return valid

func execute(combat: Combat) -> void:
	castable.create_details(combat.player)
	castable.add_target_to_details(targets)
	await combat.action_stack.process_callable(castable.cast)
	castable.reset_details()
