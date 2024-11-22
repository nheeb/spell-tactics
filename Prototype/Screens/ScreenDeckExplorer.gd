extends Control

var activity: BrowseDeckActivity
@onready var container: Control = $"ScrollContainer/Container"

func set_activity(_activity: BrowseDeckActivity):
	self.activity = _activity



func _on_back_pressed():
	ActivityManager.pop()
