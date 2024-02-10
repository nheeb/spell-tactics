@tool
class_name CombatState extends Resource

@export var level_state: LevelState
@export var current_round: int = 1
@export var current_phase: Combat.RoundPhase = Combat.RoundPhase.CombatBegin
@export var player_energy: EnergyStack
#@export var hand_size: int = 5
@export var deck_states: Array[SpellState]
@export var hand_states: Array[SpellState]
@export var discard_pile_states: Array[SpellState]
@export var event_states: Array[SpellState]
@export var current_event: SpellReference
@export var timed_effects: Array[TimedEffect]
@export var combat_log: Array[LogEntry]

const COMBAT = preload("res://Logic/Combat.tscn")

func deserialize() -> Combat:
	var combat := COMBAT.instantiate()
	combat._ready()
	combat.log.add("Deserializing Combat...")
	combat.current_round = current_round
	combat.current_phase = current_phase
	combat.energy.player_energy = player_energy
	combat.level = level_state.deserialize(combat) #its important that level is deserialized after current round phase is set
	combat.deck.append_array(deck_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.hand.append_array(hand_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.discard_pile.append_array(discard_pile_states.map(func(x: SpellState): return x.deserialize(combat)))
	if Game.DEBUG_SPELL_TESTING:
		combat.log.add("Spell Testing Deck will be loaded")
		combat.deck.clear()
		combat.deck.append_array(Utility.DeckUtils.deck_for_spell_testing(combat))
    if combat.deck.size() + combat.hand.size() + combat.discard_pile.size() < 1:
		combat.log.add("CombatState has no deck -> PrototypeDeck will be loaded")
		combat.deck.append_array(Utility.DeckUtils.create_test_deck(combat))
	combat.event.events.append_array(event_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.event.current_event = current_event
	if combat.event.events.is_empty():
		combat.event.events.append_array(Game.get_prototype_events(combat))
	combat.timed_effects = timed_effects
	combat.log.log_entries = combat_log
	combat.setup()
	combat.log.add("Combat was deserialized.")
	return combat

func save_to_disk(path: String) -> void:
	var err = ResourceSaver.save(self, path) # , ResourceSaver.FLAG_BUNDLE_RESOURCES)
	if not err == OK:
		printerr("Err when saving level state: ", err)

static func load_from_disk(path: String) -> CombatState:
	return ResourceLoader.load(path) as CombatState
