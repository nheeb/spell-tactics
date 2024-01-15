class_name CombatState extends Resource

@export var level_state: LevelState
@export var current_round: int = 1
@export var current_phase: Combat.RoundPhase = Combat.RoundPhase.Start
@export var player_energy: Array[Game.Energy]
@export var hand_size: int = 5
@export var deck_states: Array[SpellState]
@export var hand_states: Array[SpellState]
@export var discard_pile_states: Array[SpellState]

const COMBAT := preload("res://Logic/Combat.tscn")

func deserialize() -> Combat:
	var combat := COMBAT.instantiate()
	combat.level = level_state.deserialize()
	combat.current_round = current_round
	combat.current_phase = current_phase
	combat.player_energy = player_energy
	combat.hand_size = hand_size
	combat.deck.append_array(deck_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.hand.append_array(hand_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.discard_pile.append_array(discard_pile_states.map(func(x: SpellState): return x.deserialize(combat)))
	combat.update_references()
	return combat
