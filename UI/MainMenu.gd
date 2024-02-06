extends Control


func _on_start_pressed():
	ActivityManager.push(OverworldActivity.new())
