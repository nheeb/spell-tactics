class_name PostCombatActivity extends Activity

const possible_booster_packs: Array[BoosterPack] = [
	preload('res://Spells/AllBoosterPacks/BookOfAir.tres'),
	preload('res://Spells/AllBoosterPacks/BookOfAir.tres'),
	preload('res://Spells/AllBoosterPacks/BookOfFury.tres'),
]

var booster_pickup_options: Array[BoosterPickupOption] = []

func _init():
	var items = possible_booster_packs.duplicate()
	for i in range(3):
		var booster = items.pick_random()
		items.remove_at(items.find(booster))
		booster_pickup_options.append(BoosterPickupOption.new(booster))

