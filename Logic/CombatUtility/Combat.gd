class_name Combat extends Node

enum RoundPhase {
	CombatBegin = 0, # Unreachable
	Start = 1,
	# DEPRECATED Movement,
	Spell = 2, # Player Input Needed
	# DEPRECATED Pass,
	Enemy = 3,
	End = 4,
	RoundRepeats = 5, # Unreachable
}

enum Result {
	Unfinished,
	Victory,
	Loss,
	Draw
}

@onready var start_phase: StartPhase = %StartPhase
@onready var spell_phase: SpellPhase = %SpellPhase
@onready var enemy_phase: EnemyPhase = %EnemyPhase
@onready var end_phase: EndPhase = %EndPhase

@onready var animation: AnimationUtility = %AnimationUtility
@onready var cards: CardUtility = %CardUtility
@onready var energy: EnergyUtility = %EnergyUtility
@onready var movement: MovementUtility = %MovementUtility
@warning_ignore("shadowed_global_identifier")
@onready var log: LogUtility = %LogUtility
@onready var input: InputUtility = %InputUtility as InputUtility
@onready var events: EventUtility = %EventUtility
@onready var t_effects: TimedEffectsUtility = %TimedEffectsUtility
@onready var attack: AttackUtility = %AttackUtility
@onready var action_stack: ActionStackUtility = %ActionStackUtility
@onready var castables: CastableUtility = %CastableUtility

# TODO Nitai move those to the log utility
signal round_ended
signal spell_casted_successfully(spell: SpellReference)
signal deserialized

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

var global_enemy_actions: Array[EnemyActionArgs]

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
	for entity in level.entities.get_all_entities():
		if entity is PlayerEntity:
			if player != entity and player != null:
				push_error("Two players in a level??")
			player = entity
		if entity is EnemyEntity:
			if not entity.is_dead():
				enemies.append(entity)
	if player == null:
		push_error("No Player entity was found. Creating a new one.")
		@warning_ignore("integer_division")
		var position = Vector2i(level.n_rows / 2 , level.n_cols / 2)
		player = level.entities.create(position, load("res://Entities/Player/PlayerResource.tres"))
		

	# Connect input signals
	input.connect_with_event_signals()

	# Check if all entities have ids
	# Refresh entities if its CombatBegin
	if current_phase == RoundPhase.CombatBegin:
		# If it's a fresh combat make every id new
		log.add("Creating new entity ids")
		for e in level.entities.get_all_entities():
			e.id = EntityID.new(e.type, level.add_type_count(e.type))
			# set energy to the EntityType's energy in case it changed from level creation
			e.sync_with_type()
	else:
		for e in level.entities.get_all_entities():
			if e.id != null:
				level.add_type_count(e.type)
			else:
				push_error("Entity without ID in savegame")

	actives = [
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/BasicMovement.tres"), self),
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/Drain.tres"), self),
		#Active.new(ActiveType.load_from_file("res://Spells/AllActives/ThrowSpell.tres"), self),
		Active.new(ActiveType.load_from_file("res://Spells/AllActives/SimpleMelee.tres"), self),
	]
	for i in range(actives.size()): actives[i].id = ActiveID.new(i)

	# Check if all spells have ids
	# TODO change this when Overworld is done
	for s in get_all_castables():
		if s.id == null:
			if not s.get_type() is ActiveType:  # for Actives it's fine atm
				push_error("Warning: Spell without id (gets a new dangerous id)")
			var id: SpellID = SpellID.new(Game.add_to_spell_count())
			# normal assignment didn't work since Godot 4.3?? does this break things? FIXME
			s.set("id", id)
		else:
			Game.add_to_spell_count()

	# TODO connect entity & spell references

	t_effects.connect_all_effects()
	
	# Connect with ui
	ui.setup(self)
	
	# Initial Animations
	# TODO Nitai replace show drain and energy??
	#energy.show_drains_in_ui()
	#energy.show_energy_in_ui()
	if player.current_tile != null:
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
	log.register_entry(LogEntry.new("", LogEntry.Type.TurnTransition))

func get_current_phase_node() -> AbstractPhase:
	return get_phase_node(current_phase)

## ACTION Processes the current phase.
func process_current_phase() -> void:
	await get_current_phase_node()._process_phase()

func get_phase_node(phase: RoundPhase) -> AbstractPhase:
	match phase:
		RoundPhase.Start:
			return %StartPhase
		RoundPhase.Spell:
			return %SpellPhase
		RoundPhase.Enemy:
			return %EnemyPhase
		RoundPhase.End:
			return %EndPhase
		RoundPhase.RoundRepeats:
			push_error("Processes unreachble phase RoundRepeats")
	return null

## ACTION
func advance_and_process_until_next_player_action_needed():
	while true:
		advance_current_phase()
		log.add("Processing %s ..." % RoundPhase.keys()[current_phase])
		await action_stack.process_callable(process_current_phase)
		if get_current_phase_node().needs_user_input_to_proceed():
			break

func process_initial_phase() -> void:
	match current_phase:
		RoundPhase.CombatBegin:
			action_stack.push_back(advance_and_process_until_next_player_action_needed)
		RoundPhase.Spell:
			action_stack.push_back(process_current_phase)
		_:
			push_error("Savefiles should not be in phase %s" % current_phase)
			action_stack.push_back(advance_and_process_until_next_player_action_needed)

func serialize() -> CombatState:
	var state := CombatState.new()
	state.level_state = level.serialize()
	state.current_round = current_round
	state.current_phase = current_phase
	state.player_energy = energy.player_energy
	state.deck_states.append_array(deck.map(func(x: Spell): return x.serialize()))
	state.hand_states.append_array(hand.map(func(x: Spell): return x.serialize()))
	state.discard_pile_states.append_array(discard_pile.map(func(x: Spell): return x.serialize()))
	# TODO Nitai serialize events and enemy actions
	#state.event_states.append_array(events.events.map(func(x: Spell): return x.serialize()))
	#state.current_event = events.current_event
	state.timed_effects = t_effects.effects
	state.combat_log = self.log.log_entries
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

func get_all_castables() -> Array[Castable]:
	var all_spells : Array[Castable] = []
	all_spells.append_array(hand)
	all_spells.append_array(deck)
	all_spells.append_array(discard_pile)
	all_spells.append_array(actives)
	return all_spells

func get_all_enemies() -> Array[EnemyEntity]:
	return enemies.duplicate()

func get_all_hp_entities() -> Array[HPEntity]:
	var hps : Array[HPEntity] = []
	hps.append_array(get_all_enemies())
	hps.append(player)
	# TODO What about HP Entities != player or enemies?
	# Destructable environment? Will those exist?
	return hps

func get_reference() -> CombatReference:
	return CombatReference.new()

func resolve_reference(ref) -> Object:
	if ref == null:
		return null
	assert(ref is UniversalReference)
	return ref.resolve(self)
