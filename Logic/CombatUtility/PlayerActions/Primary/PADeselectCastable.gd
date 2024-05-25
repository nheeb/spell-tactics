class_name PADeselectCastable extends PlayerAction

func _init() -> void:
	action_string = "Deselect Castable"

func is_valid(combat: Combat) -> bool:
	return combat.input.current_castable != null

func execute(combat: Combat) -> void:
	combat.input.deselect_castable()

func on_fail(combat: Combat) -> void:
	pass

