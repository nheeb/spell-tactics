class_name Combat extends Node

const LEVEL = preload("res://Logic/Tiles/Level.tscn")
const ROCK_ENTITY = preload("res://Entities/Environment/Rock.tres")
const WATER_TILE_ENTITY = preload("res://Entities/Environment/WaterTile.tres")
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

@onready var animation: AnimationUtility = %AnimationUtility
@onready var cards: CardUtility = %CardUtility
@onready var energy: EnergyUtility = %EnergyUtility
@onready var movement: MovementUtility = %MovementUtility
@warning_ignore("shadowed_global_identifier")
@onready var log: LogUtility = %LogUtility


var current_round: int = 1
var current_phase: RoundPhase = RoundPhase.CombatBegin

var level: Level
var ui: CombatUI

var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

var player: PlayerEntity
var enemies: Array[EnemyEntity]

#var animation_queue: Array[AnimationObject]


func update_references() -> void:
	player = null
	enemies = []
	for entity in level.get_all_entities():
		if entity is PlayerEntity:
			if player != entity and player != null:
				printerr("Two players in a level??")
			player = entity
		if entity is EnemyEntity:
			enemies.append(entity)

func create_prototype_level():
	level = LEVEL.instantiate()
	level.name = "Level"
	level.combat = self
	level.init_basic_grid(3)
	# let's add some prototyping entities to the level
	level.fill_entity(GRASS_TERRAIN_ENTITY)
	level.create_entity(2, 2, GOBLIN_TYPE)
	level.create_entity(3, 3, ROCK_ENTITY)
	level.create_entity(3, 4, WATER_ENTITY)
	level.player = level.create_entity(0, 6, PLAYER_TYPE)

	deck = []
	for i in range(20):
		match randi_range(1,2):
			1: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/DoNothing.tres"), self))
			2: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres"), self))
	update_references()
	energy.player_energy = []
	discard_pile = []
	hand = []

func connect_with_ui(_ui: CombatUI) -> void:
	ui = _ui
	ui.combat = self
	
	# Update UI
	for spell in hand:
		ui.add_card(spell)

func advance_current_phase():
	# go to next phase
	@warning_ignore("int_as_enum_without_cast")
	current_phase += 1
	if current_phase >= RoundPhase.RoundRepeats:
		current_phase = RoundPhase.Start

## Processes the current phase. Returns true if Player input is needed to advace to the next phase
func process_current_phase() -> bool:
	return get_phase_node(current_phase).process_phase()

func get_phase_node(phase: RoundPhase) -> AbstractPhase:
	match current_phase:
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

## returns whether it is valid
func process_player_action(action: PlayerAction) -> bool:
	if action.is_valid(self):
		print("Doing Player Action: %s" % action.action_string)
		action.execute(self)
		animation.play_animation_queue()
		return true
	else:
		# should we throw an error msg here or will this happen in normal play?
		printerr("Invalid Player Action: %s" % action.action_string)
		return false

func _ready() -> void:
	Events.tile_clicked.connect(func (tile): get_phase_node(current_phase).tile_clicked(tile))
	Events.tile_hovered.connect(func(tile): get_phase_node(current_phase).tile_hovered(tile))

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
	return state

func save_to_disk(path: String = ""):
	var state: CombatState = serialize()
	var err = ResourceSaver.save(state, path) # , ResourceSaver.FLAG_BUNDLE_RESOURCES)
	
	if not err == OK:
		printerr("Err when saving level state: ", err)

static func load_from_disk(path: String) -> Combat:
	var state: CombatState = ResourceLoader.load(path) as CombatState
	return state.deserialize()

static func serialize_level_as_combat_state(_level: Level) -> CombatState:
	var state := CombatState.new()
	state.level_state = _level.serialize()
	state.current_round = 1
	state.current_phase = RoundPhase.CombatBegin
	state.player_energy = []
	state.hand_size = 5
	var useless_spell_state = SpellState.new()
	useless_spell_state.type = SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres")
	state.deck_states.append_array(range(20).map(func(x): return useless_spell_state))
	state.hand_states.append_array([])
	state.discard_pile_states.append_array([])
	return state
