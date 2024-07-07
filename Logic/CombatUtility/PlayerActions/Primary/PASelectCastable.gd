class_name PASelectCastable extends PlayerAction

var castable: Castable

func _init(_castable: Castable) -> void:
	castable = _castable
	action_string = "Select Castable <%s>" % castable

func is_valid(combat: Combat) -> bool:
	return castable.is_selectable()

func execute(combat: Combat) -> void:
	if combat.input.current_castable:
		combat.input.deselect_castable()
	combat.input.select_castable(castable)

func on_fail(combat: Combat) -> void:
	pass
