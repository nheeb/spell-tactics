class_name PABlockInput extends PlayerAction

var block := true

func _init(_block := true) -> void:
	block = _block
	action_string = "Block Input" if block else "Unblock Input"

func is_valid(combat: Combat) -> bool:
	return combat.input.input_blocked != block

func execute(combat: Combat) -> void:
	combat.input.input_blocked = block

func on_fail(combat: Combat) -> void:
	pass

