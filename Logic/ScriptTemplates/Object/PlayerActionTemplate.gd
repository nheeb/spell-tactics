class_name PAxxxxxx extends PlayerAction

func _init() -> void:
	action_string = ""
	blocking_types = [InputUtility.InputBlockType.Any]
	changes_combat = true

func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	pass

func on_fail(combat: Combat) -> void:
	pass
