extends Control

var activity: PurgeDeckActivity
@onready var container: Control = $"ScrollContainer/Container"
@onready var back: Button = $"HFlowContainer/Back"
@onready var select_label: Label = $"Label"

var chosen: Array[HandCard2D] = []
var all_cards: Array[HandCard2D] = []

func set_activity(_activity: PurgeDeckActivity):
	self.activity = _activity
	
func toggle_card(card: HandCard2D):
	if chosen.has(card):
		chosen.remove_at(chosen.find(card))
	else:
		chosen.append(card)
	update_label()
	update_selected()

func update_label():
	select_label.text = "%d / %d selected" % [len(chosen), activity.num]

func update_selected():
	for card in all_cards:
		card.set_enabled(chosen.has(card))
		if card.enabled:
			card.self_modulate = Color(1, 1, 1, 1)
		else:
			card.self_modulate = Color(1, 1, 1, 0.1)

func _ready():
	if not activity.allow_back:
		back.hide()
	for spell_state in Adventure.deck_states:
		var hand_card: HandCard2D = preload('res://UI/HandCard2D.tscn').instantiate()
		hand_card.set_spell_type(spell_state.type)
		hand_card.set_spell_state(spell_state)
		container.add_child(hand_card, true)
		hand_card.pressed.connect(toggle_card)
		hand_card.set_enabled(false)
		all_cards.append(hand_card)
	update_label()
	update_selected()

func _on_back_pressed():
	ActivityManager.pop()

func _on_purge_pressed():
	if len(chosen) > activity.num:
		return
	var spell_states: Array[SpellState] = []
	for card in chosen:
		spell_states.append(card.spell_state)
	activity.process_result(spell_states)
