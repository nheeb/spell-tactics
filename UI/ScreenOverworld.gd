extends CanvasLayer

var activity: OverworldActivity

func set_activity(_activity: OverworldActivity):
	self.activity = _activity

func _ready():
	activity.overworld = %OverworldPrototype
