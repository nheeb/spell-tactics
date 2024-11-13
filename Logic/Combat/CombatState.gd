class_name CombatState extends Resource

# TODO Add ## docstrings to the CombatState properties

## Level data: How many tiles exist and which entities are on them
@export var level_state: LevelState
@export var current_round: int = 1
@export var current_phase: Combat.RoundPhase = Combat.RoundPhase.CombatBegin
## The energy posessed by the player
@export var player_energy: EnergyStack
## All spells in player's deck (not hand or discarded)
@export var deck_states: Array[SpellState]
## All spells in player's hand
@export var hand_states: Array[SpellState]
## All spells discarded (those will be reshuffled into a new deck once the deck is empty)
@export var discard_pile_states: Array[SpellState]
## Timed Effects ( = combat persistant signal method connections )
@export var timed_effects: Array[TimedEffect]
@export var combat_log: Array[LogEntry]
## All actives
@export var active_states: Array[ActiveState]
## All Events that are currently active
@export var all_events: Array[CombatEventState]
## All events that are scheduled to happen at some point
@export var event_schedules: Array[CombatEventSchedule]
## Planned Enemy events
@export var enemy_event_queue: Array[EnemyEventPlan]
@export var current_enemy_event: CombatEventReference
## Progress of the enemy meter
@export var enemy_meter: int
## Enemy Actions
@export var global_enemy_actions: Array[EnemyActionArgs]
## Highest ID given (for adding new ids)
@export var highest_id: int
@export var meta: SaveFileMeta = null

const COMBAT = preload("res://Logic/Combat/Combat.tscn")

func deserialize() -> Combat:
	var combat : Combat = COMBAT.instantiate() as Combat
	combat._ready()
	for c in combat.get_children():
		for cc in c.get_children():
			cc.set("combat", combat)
	combat.log.add("Deserializing Combat...")
	# Rounds & Energy
	combat.current_round = current_round
	combat.current_phase = current_phase
	combat.energy.player_energy = player_energy
	# Level
	if level_state == null:
		push_error("Error deserializing: LevelState null in CombatState.gd")
	#its important that level is deserialized after current round phase is set
	combat.level = level_state.deserialize(combat)
	combat.level._ready()
	# Cards
	combat.deck.append_array(deck_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.hand.append_array(hand_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.discard_pile.append_array(discard_pile_states.map(func(x: SpellState): return x.deserialize(combat)))
	# Events
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
	combat.ids.highest_id = highest_id
	
	# TODO Do this in general with all CombatObjects
	# Add castable ids
	for c in combat.get_all_castables():
		combat.ids.add_combat_object(c)
	# Add entity ids
	for e in combat.level.entities.get_all_entities():
		combat.ids.add_combat_object(e)
	
	combat.deserialized.emit()
	combat.log.add("Combat was deserialized.")
	return combat

func save_to_disk(path: String) -> void:
	var err = ResourceSaver.save(self, path) # , ResourceSaver.FLAG_BUNDLE_RESOURCES)
	if not err == OK:
		push_error("Err when saving level state: ", err)

static func load_from_disk(path: String) -> CombatState:
	return ResourceLoader.load(path) as CombatState
	
func generate_meta(save_name: String = "Unnamed Savefile", screenshot : ImageTexture = null) -> void:
	meta = SaveFileMeta.new()
	meta.title = save_name
	meta.timestamp = Time.get_datetime_string_from_system()

	if screenshot:
		meta.screenshot = screenshot
	else:
		meta.screenshot = Utility.take_screenshot(3)
	meta.filename = "Savefile-" + meta.timestamp.replace(":", "-").replace("T", "-")\
			 + "-" + meta.title.replace(" ", "")
