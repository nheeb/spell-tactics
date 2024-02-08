@tool
class_name Combat extends Node

const LEVEL = preload("res://Logic/Tiles/Level.tscn")
const ROCK_ENTITY = preload("res://Entities/Environment/Rock.tres")
const WATER_ENTITY = preload("res://Entities/Environment/Water.tres")
const GRASS_TERRAIN_ENTITY = preload("res://Entities/Environment/GrassTile.tres")
const PLAYER_TYPE = preload("res://Entities/PlayerResource.tres")
const GOBLIN_TYPE = preload("res://Entities/Enemies/Goblin.tres")

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

enum RESULT {
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
@onready var input: InputUtility = %InputUtility
@onready var event: EventUtility = %EventUtility

signal round_ended
signal spell_casted_successfully(spell: SpellReference)

var result: RESULT = RESULT.Unfinished
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

var timed_effects: Array[TimedEffect]

func _ready() -> void:
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
	Events.tile_clicked.connect(func (tile): get_phase_node(current_phase).tile_clicked(tile))
	Events.tile_hovered.connect(func(tile): get_phase_node(current_phase).tile_hovered(tile))

	# Check if all entities have ids
	# Refresh entities if its CombatBegin
	if current_phase == RoundPhase.CombatBegin:
		# If it's a fresh combat make every id new
		log.add("Creating new entity ids")
		for e in level.entities().get_all_entities():
			e.id = EntityID.new(e.type, level.add_type_count(e.type))
			e.energy = e.type.energy
	else:
		for e in level.entities().get_all_entities():
			if e.id != null:
				level.add_type_count(e.type)
			else:
				printerr("Entity without ID in savegame")

	# Check if all spells have ids
	# TODO change this when Overworld is done
	for s in get_all_spells():
		if s.id == null:
			printerr("Warning: Spell without id (gets a new dangerous id)")
			s.id = SpellID.new(Game.add_to_spell_count())
		else:
			Game.add_to_spell_count()

	# TODO connect entity & spell references
	
	actives = [Active.new(SpellType.load_from_file("res://Spells/AllActives/SimpleMelee.tres"), self)]

func connect_with_ui_and_camera(_ui: CombatUI, cam: GameCamera = null) -> void:
	ui = _ui
	ui.setup(self)
	camera = cam

func advance_current_phase():
	# go to next phase
	@warning_ignore("int_as_enum_without_cast")
	current_phase += 1
	if current_phase >= RoundPhase.RoundRepeats:
		current_phase = RoundPhase.Start

## Processes the current phase. Returns true if Player input is needed to advace to the next phase
func process_current_phase() -> bool:
	return get_phase_node(current_phase)._process_phase()

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

func serialize() -> CombatState:
	var state := CombatState.new()
	state.level_state = level.serialize()
	state.current_round = current_round
	state.current_phase = current_phase
	state.player_energy = energy.player_energy
	# should be serialized in Player from now on
	#state.hand_size = hand_size
	state.deck_states.append_array(deck.map(func(x: Spell): return x.serialize()))
	state.hand_states.append_array(hand.map(func(x: Spell): return x.serialize()))
	state.discard_pile_states.append_array(discard_pile.map(func(x: Spell): return x.serialize()))
	state.event_states.append_array(event.events.map(func(x: Spell): return x.serialize()))
	state.current_event = event.current_event
	state.timed_effects = timed_effects
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

func get_all_spells() -> Array[Spell]:
	var all_spells : Array[Spell] = []
	all_spells.append_array(hand)
	all_spells.append_array(deck)
	all_spells.append_array(discard_pile)
	all_spells.append_array(event.events)
	return all_spells

func resolve_reference(ref) -> Object:
	if ref == null:
		return null
	assert(ref is EntityReference or ref is SpellReference)
	return ref.resolve(self)

func get_all_enemies() -> Array[EnemyEntity]:
	return enemies.duplicate()
