extends Control

@onready var grid: Control = $"PickBoosterPopup/VBoxContainer/GridContainer"

func _on_continue_pressed():
	ActivityManager.pop()

func start(activity: PostCombatActivity):
	for option in activity.booster_pickup_options:
		var option_ui = preload("res://UI/PostBattle/BoosterPickOption.tscn").instantiate()
		option_ui.booster_pickup_option = option
		grid.add_child(option_ui)

	var choose_coin = preload("res://UI/PostBattle/CoinsPickOption.tscn").instantiate()
	grid.add_child(choose_coin)


func _on_skip_pressed():
	ActivityManager.pop()
