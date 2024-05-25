class_name Castable extends Object

var combat: Combat

var combat_persistant_properties := {}
var round_persistant_properties := {}

var cast_success := true

func get_effect_text() -> String:
	return "<Effect Text not implemented>"

func is_selectable() -> bool:
	return false

func is_castable() -> bool:
	return false

func try_cast() -> void:
	cast_success = true
	# Cast effect

func mark_cast_failed() -> void:
	cast_success = false

func was_cast_successful() -> bool:
	return cast_success

func select():
	pass

func deselect():
	pass
