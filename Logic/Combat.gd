class_name Combat extends Node

@onready var animation_utility: AnimationUtility = %AnimationUtility
@onready var card_utility: CardUtility = %CardUtility
@onready var energy_utility: EnergyUtility = %EnergyUtility
@onready var movement_utility: MovementUtility = %MovementUtility
@onready var ui_utility: UiUtility = %UiUtility

enum RoundPhase {
	Start = 1,
	Movement = 2, # Player Input
	Spell = 3, # Player Input
	Pass = 4,
	Enemy = 5,
	End = 6,
	RoundRepeats = 7,
}

var current_round: int = 1
var current_phase: RoundPhase = RoundPhase.Start

var level: Level

var hand_size: int
var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

var player: PlayerEntity
var enemies: Array[EnemyEntity]
var player_energy: Array[Game.Energy]

var animation_queue: Array[AnimationObject]

func create_from_resource():
	# TODO Load Combat State
	pass

func create_as_prototype(_level: Level):
	level = _level
	deck = []
	for i in range(20):
		match randi_range(1,2):
			1: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/DoNothing.tres")))
			2: deck.append(Spell.new(SpellType.load_from_file("res://Spells/AllSpells/SelfDamage.tres")))
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

func advance_current_phase():
	# go to next phase
	@warning_ignore("int_as_enum_without_cast")
	current_phase += 1
	if current_phase == RoundPhase.RoundRepeats:
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
		if process_current_phase():
			break

func process_player_action(action: PlayerAction):
	if action.is_valid():
		action.execute()
	else:
		printerr("Invalid Player Action: %s" % action.action_string)

func _ready() -> void:
	Events.tile_clicked.connect(func (tile): process_player_action(PlayerMovement.new(tile)))
