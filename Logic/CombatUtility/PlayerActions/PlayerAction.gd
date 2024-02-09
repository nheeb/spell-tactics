class_name PlayerAction extends Object

var action_string := "<Undefined>"

func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	pass

func on_fail(combat: Combat) -> void:
	combat.log.add("Action failed: %s" % action_string)
