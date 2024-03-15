class_name AnimationCombatChoice extends AnimationObject

var combat_choice: CombatChoiceActivity

## Time to wait
func _init(_combat_choice) -> void:
	combat_choice = _combat_choice

func play(level: Level):
	ActivityManager.push(combat_choice)
	await combat_choice.resolved
	ActivityManager.pop()
	await VisualTime.visual_process
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Combat Choice"
