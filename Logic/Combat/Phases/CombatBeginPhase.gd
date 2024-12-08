class_name CombatBeginPhase extends CombatPhase

const MOVE  = "res://Content/Actives/BasicMovement.tres"
const DRAIN = "res://Content/Actives/Drain.tres"
const MELEE = "res://Content/Actives/SimpleMelee.tres"
const INTERACT = "res://Content/Actives/Interact.tres"

func process_phase() -> void:
	# Create Deck
	if Game.DEBUG_SPELL_TESTING:
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
			ActiveType.load_from_file(MELEE).create(combat),
			ActiveType.load_from_file(INTERACT).create(combat)
		]
	combat.ui.initialize_active_buttons(combat.actives)
	
	# Initial Animation
	if combat.player.current_tile != null:
		combat.animation.camera_reach(combat.player.current_tile)
	
	combat.cards.draw_to_hand_size()
	
	combat.action_stack.mark_combat_changed()

func _to_string() -> String:
	return "CombatBeginPhase"
