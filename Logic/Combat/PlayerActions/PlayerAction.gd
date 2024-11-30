class_name PlayerAction extends RefCounted

signal executed
signal failed

var action_string := "Undefined"

func is_valid(combat: Combat) -> bool:
	return true

## ACTION
func execute(combat: Combat) -> void:
	pass

## ACTION
func on_fail(combat: Combat) -> void:
	pass

func log_me(combat: Combat, valid: bool) -> void:
	return
	#combat.log.add("New Action: %s [%s]" % [action_string,
							#"VALID" if valid else "INVALID"])

func _to_string() -> String:
	return "PA:%s" % action_string
