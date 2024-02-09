class_name AnimationPlayerChoice extends AnimationObject

var player_choice: PlayerChoiceActivity

## Time to wait
func _init(_player_choice) -> void:
	player_choice = _player_choice

func play(level: Level):
	ActivityManager.push(player_choice)
	await player_choice.resolved
	ActivityManager.pop()
	await VisualTime.visual_process
	animation_done_internally.emit()

func _to_string() -> String:
	return "Anim: Player Choice"
