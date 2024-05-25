class_name CastableLogic extends Object

var combat: Combat
var target # Tile

func is_selectable() -> bool:
	return _is_selectable()

func is_castable() -> bool:
	return _is_castable()

var cast_success := true

func try_cast() -> void:
	cast_success = true
	casting_effect()
	after_cast()

func mark_cast_failed() -> void:
	cast_success = false

func was_cast_successful() -> bool:
	return cast_success

func after_cast() -> void:
	pass

####################
## For overriding ##
####################

func _is_selectable() -> bool:
	return true

func _is_castable() -> bool:
	return true

func casting_effect():
	pass
