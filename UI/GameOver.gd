extends Control

func _on_continue_pressed():
	ActivityManager.pop()
	ActivityManager.pop()

func _on_review_pressed() -> void:
	ActivityManager.substitute(ReviewActivity.new())
