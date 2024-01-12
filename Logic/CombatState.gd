class_name CombatState extends Node

enum RoundPhase {
	Start = 1,
	Movement = 2, # Player Input
	Spell = 3, # Player Input
	Pass = 4,
	Enemy = 5,
	End = 6
}

var current_round: int = 1
var current_phase: RoundPhase = RoundPhase.Start

var tile_grid: TileGrid
var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

var player: Entity
var enemies: Entity
var player_energy: Array[Game.Energy]

var animation_queue: Array

func create_from_resource():
	pass

func process_phase():
	pass

func process_player_input():
	pass
