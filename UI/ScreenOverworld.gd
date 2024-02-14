extends CanvasLayer

var activity: OverworldActivity


func set_activity(_activity: OverworldActivity):
	self.activity = _activity

func _ready():
	activity.overworld = %OverworldPrototype
	if activity.overworld_state:
		activity.overworld.deserialize(activity.overworld_state)
		if activity.overworld_state.combat_state:
			ActivityManager.push(CombatActivity.new("", activity.overworld_state.combat_state))
