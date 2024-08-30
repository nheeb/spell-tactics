class_name PAQuickCast extends PlayerAction

var castable: Castable
var targets: Array[Tile] = []

func _init(_castable: Castable, _targets: Array[Tile] = []) -> void:
	castable = _castable
	targets = _targets
	action_string = "Quick Cast <%s> on [%s]" % [castable, targets]

func is_valid(combat: Combat) -> bool:
	if castable is Spell:
		# TODO Nitai implement for spells? Is this necesarry?
		push_error("Quick cast for spells is not implemented.")
		return false
	castable.update_possible_targets()
	castable.reset_targets()
	castable.targets = targets
	return castable.is_selectable() and castable.is_castable()

func execute(combat: Combat) -> void:
	castable.try_cast()
	castable.reset_targets()

func on_fail(combat: Combat) -> void:
	pass
