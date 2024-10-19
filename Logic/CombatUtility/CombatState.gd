
class_name CombatState extends Resource

# TODO Add ## docstrings to the CombatState properties

@export var level_state: LevelState
@export var current_round: int = 1
@export var current_phase: Combat.RoundPhase = Combat.RoundPhase.CombatBegin
@export var player_energy: EnergyStack
@export var deck_states: Array[SpellState]
@export var hand_states: Array[SpellState]
@export var discard_pile_states: Array[SpellState]
@export var timed_effects: Array[TimedEffect]
@export var combat_log: Array[LogEntry]
@export var active_states: Array[ActiveState]
# Events
@export var all_events: Array[CombatEventState]
@export var event_schedules: Array[CombatEventSchedule]
@export var enemy_event_queue: Array[EnemyEventPlan]
@export var current_enemy_event: CombatEventReference
@export var enemy_meter: int
# Enemy Actions
@export var global_enemy_actions: Array[EnemyActionArgs]

const COMBAT = preload("res://Logic/CombatUtility/Combat.tscn")

func deserialize() -> Combat:
	var combat : Combat = COMBAT.instantiate() as Combat
	combat._ready()
	combat.log.add("Deserializing Combat...")
	combat.current_round = current_round
	combat.current_phase = current_phase
	combat.energy.player_energy = player_energy
	if level_state == null:
		push_error("Error deserializing: LevelState null in CombatState.gd")
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
	#combat.events.events.append_array(event_states.map(func(x: SpellState): return x.deserialize(combat)))
	#combat.events.current_event = current_event
	#if combat.events.events.is_empty():
		#combat.events.events.append_array(Game.get_prototype_events(combat))
	combat.events.all_events.append_array(all_events.map(
		func (e): return e.deserialize(combat)
	))
	combat.events.event_schedules = event_schedules
	combat.events.enemy_event_queue = enemy_event_queue
	combat.events.current_enemy_event = current_enemy_event
	combat.events.enemy_meter = enemy_meter
	combat.global_enemy_actions = global_enemy_actions
	combat.t_effects.effects = timed_effects
	combat.log.log_entries = combat_log
	combat.deserialized.emit()
	combat.log.add("Combat was deserialized.")
	return combat

func save_to_disk(path: String) -> void:
	var err = ResourceSaver.save(self, path) # , ResourceSaver.FLAG_BUNDLE_RESOURCES)
	if not err == OK:
		push_error("Err when saving level state: ", err)

static func load_from_disk(path: String) -> CombatState:
	return ResourceLoader.load(path) as CombatState
