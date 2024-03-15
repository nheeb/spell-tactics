class_name CombatChoiceActivity extends Activity
## Abstract class for all incombat descisions the player makes

@export var dont_hide_other_views := true

var result: Variant
signal resolved(result)

func _resolve(_result: Variant) -> void:
	result = _result
	resolved.emit(result)

func get_result() -> Variant:
	return result
