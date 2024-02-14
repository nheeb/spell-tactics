class_name OverworldActivity extends Activity

var overworld: Overworld
var overworld_state: OverworldState

func _init(_overworld_state: OverworldState = null) -> void:
	overworld_state = _overworld_state
