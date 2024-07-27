class_name CombatReference extends UniversalReference

var _combat: Combat

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	_combat = combat

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return _combat

func get_reference_type() -> String:
	return "CombatReference"
