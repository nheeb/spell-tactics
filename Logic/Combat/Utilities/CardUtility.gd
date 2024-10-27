class_name CardUtility extends CombatUtility

const START_HAND_SIZE = 3

func shuffle_deck():
	combat.deck.shuffle()

func discard(spell: Spell):
	if combat.hand.has(spell):
		combat.hand.erase(spell)
		combat.discard_pile.append(spell)
		combat.animation.call_method(combat.ui.cards3d, "remove_card", [spell])
		combat.animation.call_method(combat.ui, "deselect_card", [])
	else:
		push_error("Tried to discard spell which is not in hand")

func fetch_from_discard(spell: Spell):
	if combat.discard_pile.has(spell):
		combat.discard_pile.erase(spell)
		combat.hand.append(spell)
		combat.animation.call_method(combat.ui.cards3d, "add_card", [spell])
	else:
		push_error("Tried to fetch a spell from discard_pile which is not there")

func draw() -> AnimationObject:
	if combat.deck.is_empty():
		reshuffle()
	var spell : Spell = combat.deck.pop_front()
	combat.hand.append(spell)
	return combat.animation.call_method(combat.ui.cards3d, "add_card", [spell])

func draw_to_hand_size():
	# TODO make some start hand
	while combat.hand.size() < START_HAND_SIZE and can_draw():
		draw()

func can_draw():
	return len(combat.deck) > 0 or len(combat.discard_pile) > 0

func reshuffle():
	combat.deck.append_array(combat.discard_pile)
	combat.discard_pile.clear()
	shuffle_deck()
