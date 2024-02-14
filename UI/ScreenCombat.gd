extends CanvasLayer

var activity: CombatActivity

func set_activity(_activity: CombatActivity):
	self.activity = _activity

func _ready():
	if activity.combat_state:
		%World.load_combat_from_state(activity.combat_state)
	elif activity.level_path:
		%World.load_combat_from_path(activity.level_path)
	else:
		printerr("Invalid Combat Activity")
	activity.combat = %World.get_node("Combat")
