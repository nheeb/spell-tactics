extends Control

@export var booster_packs: Array[BoosterPack] = []

@onready var grid: Control = $"PickBoosterPopup/VBoxContainer/GridContainer"

func _on_continue_pressed():
	Game.view_orchestrator.transition_to_overworld()

func _ready():
	var items = booster_packs.duplicate()
	var booster_1 = items.pick_random()
	items.remove_at(items.find(booster_1))
	var booster_2 = items.pick_random()
	items.remove_at(items.find(booster_2))
	var booster_3 = items.pick_random()
	items.remove_at(items.find(booster_3))

	var boosters = [booster_1, booster_2, booster_3]
	for booster in boosters:
		var option = preload("res://UI/PostBattle/BoosterPickOption.tscn").instantiate()
		option.booster_pack = booster
		grid.add_child(option)

	var choose_coin = preload("res://UI/PostBattle/CoinsPickOption.tscn").instantiate()
	grid.add_child(choose_coin)
