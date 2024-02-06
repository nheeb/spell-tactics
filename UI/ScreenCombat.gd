extends CanvasLayer

var activity: CombatActivity

func set_activity(activity: CombatActivity):
	self.activity = activity

func _ready():
	%World.start_combat(activity.level_path)
