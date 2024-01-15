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

@onready var animation_utility: AnimationUtility = %AnimationUtility
@onready var card_utility: CardUtility = %CardUtility
@onready var energy_utility: EnergyUtility = %EnergyUtility
@onready var movement_utility: MovementUtility = %MovementUtility
@onready var ui_utility: UiUtility = %UiUtility

var current_round: int = 1
var current_phase: RoundPhase = RoundPhase.CombatBegin

var level: Level
var ui: CombatUI

var hand_size: int
var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

var player: PlayerEntity
var enemies: Array[EnemyEntity]
var player_energy: Array[Game.Energy]

var animation_queue: Array[AnimationObject]

func update_references() -> void:
	player = null
	enemies = []
	for entity in level.get_all_entities():
		if entity is PlayerEntity:
			if player != entity and player != null:
				printerr("Two players in a level??")
			player = entity
		elif entity is EnemyEntity:
			enemies.append(entity)

func create_as_prototype(_level: Level):
	level = _level
	deck = []
	for i in range(20):
		match randi_range(1,2):
			1: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/DoNothing.tres"), self))
			2: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres"), self))
	enemies = []
	for entity in level.get_all_entities():
		if entity is PlayerEntity:
			player = entity
		elif entity is EnemyEntity:
			enemies.append(entity)
	player_energy = []
	animation_queue = []
	discard_pile = []
	hand = []
	hand_size = 5

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
		print("Processing phase %s ..." % current_phase)
		if process_current_phase(): # If Player Input needed
			break

func process_player_action(action: PlayerAction):
	if action.is_valid(self):
		print("Doing Player Action: %s" % action.action_string)
		action.execute(self)
		animation_utility.play_animation_queue()
	else:
		printerr("Invalid Player Action: %s" % action.action_string)

func _ready() -> void:
	Events.tile_clicked.connect(func (tile): process_player_action(PlayerMovement.new(tile)))

func serialize() -> CombatState:
	var state := CombatState.new()
	state.level_state = level.serialize()
	state.current_round = current_round
	state.current_phase = current_phase
	state.player_energy = player_energy
	state.hand_size = hand_size
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


