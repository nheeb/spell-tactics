extends CanvasLayer

var activity: CombatActivity

func set_activity(_activity: CombatActivity):
	self.activity = _activity

func _ready():
	%World.start_combat(activity.level_path)