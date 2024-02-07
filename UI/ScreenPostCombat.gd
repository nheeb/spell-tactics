extends CanvasLayer

var activity: PostCombatActivity

func set_activity(activity: PostCombatActivity):
	self.activity = activity

func _ready():
	$PostBattle.start(activity)
