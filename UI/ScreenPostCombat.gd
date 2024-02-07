extends CanvasLayer

var activity: PostCombatActivity

func set_activity(_activity: PostCombatActivity):
	self.activity = _activity

func _ready():
	$PostBattle.start(activity)
