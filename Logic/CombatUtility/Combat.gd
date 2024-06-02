@tool
class_name Combat extends Node

enum RoundPhase {
	CombatBegin = 0, # Unreachable
	Start = 1,
	Movement = 2, # Player Input
	Spell = 3, # Player Input
	Pass = 4,
	Enemy = 5,
	End = 6,
	RoundRepeats = 7, # Unreachable
}

enum Result {
	Unfinished,
	Victory,
	Loss,
	Draw
}

@onready var animation: AnimationUtility = %AnimationUtility
@onready var cards: CardUtility = %CardUtility
@onready var energy: EnergyUtility = %EnergyUtility
@onready var movement: MovementUtility = %MovementUtility
@warning_ignore("shadowed_global_identifier")
@onready var log: LogUtility = %LogUtility
@onready var input: InputUtility = %InputUtility as InputUtility
@onready var event: EventUtility = %EventUtility
@onready var t_effects: TimedEffectsUtility = %TimedEffectsUtility
@onready var attack: AttackUtility = %AttackUtility

signal round_ended
signal spell_casted_successfully(spell: SpellReference)

var result: Result = Result.Unfinished
var current_round: int = 1
var current_phase: RoundPhase = RoundPhase.CombatBegin

var level: Level
var ui: CombatUI
var camera: GameCamera

var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

## combat, items, etc.
var actives: Array[Active]

var player: PlayerEntity
var enemies: Array[EnemyEntity]

func _ready() -> void:
	if not Engine.is_editor_hint():
		if self not in Game.combats:
			for c in Game.combats:
				c.queue_free()
			Game.combats.clear()
			Game.combats.append(self)

## is called when the Combat is created to connect all the references and signals
func setup() -> void:
	# Get player and enemy references
	player = null
	enemies = []
	for entity in level.entities().get_all_entities():
		if entity is PlayerEntity:
			if player != entity and player != null:
				printerr("Two players in a level??")
			player = entity
		if entity is EnemyEntity:
			if not entity.is_dead():
				enemies.append(entity)

	# Connect input signals
	input.connect_with_event_signals()

	# Check if all entities have ids
	# Refresh entities if its CombatBegin
	if current_phase == RoundPhase.CombatBegin:
		# If it's a fresh combat make every id new
		log.add("Creating new entity ids")
		for e in level.entities().get_all_entities():
			e.id = EntityID.new(e.type, level.add_type_count(e.type))
			# set energy to the EntityType's energy in case it changed from level creation
			e.sync_with_type()
	else:
		for e in level.entities().get_all_entities():
			if e.id != null:
				level.add_type_count(e.type)
			else:
				printerr("Entity without ID in savegame")

	
	actives = [
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/SimpleMelee.tres"), self),
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/ThrowSpell.tres"), self),
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/BasicMovement.tres"), self),
	]


	# Check if all spells have ids
	# TODO change this when Overworld is done
	for s in get_all_spells():
		if s.id == null:
			printerr("Warning: Spell without id (gets a new dangerous id)")
			s.id = SpellID.new(Game.add_to_spell_count())
		else:
			Game.add_to_spell_count()

	# TODO connect entity & spell references

	t_effects.connect_all_effects()
	
	# Connect with ui
	ui.setup(self)
	
	# Initial Animations
	energy.show_drains_in_ui()
	energy.show_energy_in_ui()
	animation.camera_reach(player.current_tile)

func connect_with_ui_and_camera(_ui: CombatUI, cam: GameCamera = null) -> void:
	ui = _ui
	camera = cam

func advance_current_phase():
	# go to next phase
	@warning_ignore("int_as_enum_without_cast")
	current_phase += 1
	if current_phase >= RoundPhase.RoundRepeats:
		current_phase = RoundPhase.Start

func get_current_phase_node() -> AbstractPhase:
	return get_phase_node(current_phase)

## Processes the current phase. Returns true if Player input is needed to advace to the next phase
func process_current_phase() -> bool:
	return get_current_phase_node()._process_phase()

func get_phase_node(phase: RoundPhase) -> AbstractPhase:
	match phase:
		RoundPhase.Start:
			return %StartPhase
		RoundPhase.Movement:
			return %MovementPhase
		RoundPhase.Spell:
			return %SpellPhase
		RoundPhase.Pass:
			return %PassPhase
		RoundPhase.Enemy:
			return %EnemyPhase
		RoundPhase.End:
			return %EndPhase
		RoundPhase.RoundRepeats:
			printerr("Processes unreachble phase RoundRepeats")
	return null

func advance_and_process_until_next_player_action_needed():
	while true:
		advance_current_phase()
		print("Processing %s ..." % RoundPhase.keys()[current_phase])
		if process_current_phase(): # If Player Input needed
			break

func process_initial_phase() -> void:
	match current_phase:
		RoundPhase.CombatBegin:
			advance_and_process_until_next_player_action_needed()
		RoundPhase.Start:
			advance_current_phase()
			process_current_phase()
		RoundPhase.Movement:
			process_current_phase()
		RoundPhase.Spell:
			process_current_phase()
		_:
			printerr("Savefiles should not be in phase %s" % current_phase)
			advance_and_process_until_next_player_action_needed()

func serialize() -> CombatState:
	var state := CombatState.new()
	state.level_state = level.serialize()
	state.current_round = current_round
	state.current_phase = current_phase
	state.player_energy = energy.player_energy
	state.deck_states.append_array(deck.map(func(x: Spell): return x.serialize()))
	state.hand_states.append_array(hand.map(func(x: Spell): return x.serialize()))
	state.discard_pile_states.append_array(discard_pile.map(func(x: Spell): return x.serialize()))
	state.event_states.append_array(event.events.map(func(x: Spell): return x.serialize()))
	state.current_event = event.current_event
	state.timed_effects = t_effects.effects
	state.combat_log = self.log.log_entries
	state.drains_done = energy.drains_done_this_turn
	return state

func save_to_disk(path: String = ""):
	var state: CombatState = serialize()
	state.save_to_disk(path)

static func load_from_disk(path: String) -> Combat:
	var state: CombatState = CombatState.load_from_disk(path)
	return state.deserialize()

@warning_ignore("shadowed_variable")  # stupid that static funcs raise a shadow warning but ok..
static func serialize_level_as_combat_state(level: Level) -> CombatState:
	var state := CombatState.new()
	state.level_state = level.serialize()
	return state

static func deserialize_level_from_combat_state(combat_state: CombatState) -> Level:
	var combat := combat_state.deserialize()
	return combat.level

func get_all_spells() -> Array[Castable]:
	var all_spells : Array[Castable] = []
	all_spells.append_array(hand)
	all_spells.append_array(deck)
	all_spells.append_array(discard_pile)
	all_spells.append_array(event.events)
	all_spells.append_array(actives)
	return all_spells

func get_all_enemies() -> Array[EnemyEntity]:
	return enemies.duplicate()

func get_reference() -> CombatReference:
	return CombatReference.new()

func resolve_reference(ref) -> Object:
	if ref == null:
		return null
	assert(ref is UniversalReference)
	return ref.resolve(self)
