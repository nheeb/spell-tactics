class_name PostCombatActivity extends Activity

const possible_booster_packs: Array[BoosterPack] = [
	preload("res://Prototype/BoosterPacks/BookOfAir.tres"),
]

var booster_pickup_options: Array[BoosterPickupOption] = []
var coin_pickup_option: CoinPickupOption = null

func _init():
	coin_pickup_option = CoinPickupOption.new(randi_range(25, 125))
	
	for booster_pack in possible_booster_packs:
		booster_pack.initialise()
	var items = possible_booster_packs.duplicate()	
	for i in range(3):
		var booster = items.pick_random()
		items.remove_at(items.find(booster))
		booster_pickup_options.append(BoosterPickupOption.new(booster))
