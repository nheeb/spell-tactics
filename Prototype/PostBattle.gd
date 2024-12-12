extends Control

@onready var grid: Control = $"PickBoosterPopup/VBoxContainer/GridContainer"

func start(activity: PostCombatActivity):
	for option in activity.booster_pickup_options:
		#var option_ui = preload("res://UI/PostBattle/BoosterPickOption.tscn").instantiate()
		#option_ui.booster_pickup_option = option
		#grid.add_child(option_ui)
		pass

	#var choose_coin = preload("res://UI/PostBattle/CoinsPickOption.tscn").instantiate()
	#choose_coin.coin_pickup_option = activity.coin_pickup_option
	#grid.add_child(choose_coin)


func _on_skip_pressed():
	ActivityManager.pop()

func _on_review_pressed() -> void:
	ActivityManager.push(ReviewActivity.new())


func _on_booster_pressed() -> void:
	$PickBoosterPopup.visible = not $PickBoosterPopup.visible

func _on_rest_pressed():
	Adventure.heal(10)
	ActivityManager.pop()

func _on_purge_pressed():
	pass
	#ActivityManager.substitute(PurgeDeckActivity.new(1, true))

func _on_march_on_pressed():
	ActivityManager.pop()
