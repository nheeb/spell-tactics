class_name AdventureSingleton extends Node

@export var health: int = 0
@export var coins: int = 0
@export var deck_states: Array[SpellState]

func reset():
	health = 10
	coins = 0
	deck_states = []
	
func sync_health(amount: int):
	health = amount

func heal(amount: int):
	health += amount

func damage(amount: int):
	health -= amount
	# TODO: Death check?

func add_cards(cards: Array[SpellState]):
	deck_states.append_array(cards)
	
func remove_cards(cards: Array[SpellState]):
	for card in cards:
		var index = deck_states.find(card)
		if index != -1:
			deck_states.remove_at(index)

func serialise():
	var adventure_state = AdventureState.new()
	adventure_state.health = health
	adventure_state.coins = coins
	adventure_state.deck_states = deck_states
	return adventure_state

func deserialise(adventure_state: AdventureState):
	self.health = adventure_state.health
	self.coins = adventure_state.coins
	self.deck_states = adventure_state.deck_states
