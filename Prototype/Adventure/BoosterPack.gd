class_name BoosterPack extends Resource

@export var name: String = ""
@export var entries: Array[BoosterPackEntry] = []

func initialise():
	for entry in entries:
		entry.spell_type._on_load()

func select_cards(count: int) -> Array[SpellType]:
	var cards : Array[SpellType] = []
	for i in range(count):
		var card = select_card()
		cards.append(card)
	return cards
	
func select_card() -> SpellType:
	var total = 0
	for entry in entries:
		total += entry.pickup_chance
	var random = randf_range(0, total)
	
	var accumulator = 0
	for entry in entries:
		accumulator += entry.pickup_chance
		if accumulator > random:
			return entry.spell_type
	return null
