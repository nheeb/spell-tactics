class_name CombatBeginPhase extends CombatPhase

const MOVE  = "res://Content/Actives/BasicMovement.tres"
const DRAIN = "res://Content/Actives/Drain.tres"
const MELEE = "res://Content/Actives/SimpleMelee.tres"

func process_phase() -> void:
	# TODO Do this in general with all CombatObjects
	# entities sync with type
	for e in combat.level.entities.get_all_entities():
		e.sync_with_type()
	
	# Create Deck
	if Game.SPELL_TEST:
		combat.log.add("Spell Testing Deck will be loaded")
		combat.deck.clear()
		combat.deck.append_array(Game.DeckUtils.deck_for_spell_testing(combat))
	if combat.deck.size() + combat.hand.size() + combat.discard_pile.size() < 1:
		combat.log.add("Level has no deck -> PrototypeDeck will be loaded")
		combat.deck.append_array(Game.DeckUtils.create_test_deck(combat))
	# Create actives
	if combat.actives.is_empty():
		combat.log.add("Level has no actives -> Regular actives will be loaded")
		combat.actives = [
			ActiveType.load_from_file(MOVE).create(combat),
			ActiveType.load_from_file(DRAIN).create(combat),
			ActiveType.load_from_file(MELEE).create(combat)
		]
	combat.ui.initialize_active_buttons(combat.actives)
	combat.cards.draw_to_hand_size()

func _to_string() -> String:
	return "CombatBeginPhase"
