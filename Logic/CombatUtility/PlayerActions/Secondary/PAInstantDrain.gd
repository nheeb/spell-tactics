extends PlayerAction

func _init() -> void:
	action_string = ""

func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	pass

func on_fail(combat: Combat) -> void:
	pass

