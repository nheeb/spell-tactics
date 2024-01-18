class_name CardUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func shuffle_deck():
	combat.deck.shuffle()

func discard(spell: Spell):
	if combat.hand.has(spell):
		combat.hand.erase(spell)
		combat.discard_pile.append(spell)
		combat.animation.callback(combat.ui, "remove_card", [spell])
		combat.animation.callback(combat.ui, "deselect_card", [])
	else:
		printerr("Tried to discard spell which is not in hand")

func draw():
	if not combat.deck.is_empty():
		var spell : Spell = combat.deck.pop_front()
		combat.hand.append(spell)
		combat.animation.callback(combat.ui, "add_card", [spell])

func draw_to_hand_size():
	while combat.hand.size() < combat.player.traits.max_handsize:
		draw()
