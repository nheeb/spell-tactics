class_name BoosterPickupOption extends Object

var booster_pack: BoosterPack

func _init(_booster_pack: BoosterPack):
	self.booster_pack = _booster_pack

func apply() -> bool:
	var selected_cards = booster_pack.select_cards(3)
	var spell_states: Array[SpellState] = []
	for card in selected_cards:
		var spell_id = SpellID.new()
		spell_id.id = randi() # TODO - incremental?
		var spell_state = SpellState.new()
		spell_state.id = spell_id
		spell_state.type = card
		spell_states.append(spell_state)
	Adventure.add_cards(spell_states)
	return true
