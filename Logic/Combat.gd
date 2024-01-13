class_name Combat extends Node

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
var deck: Array[Spell]
var hand: Array[Spell]
var discard_pile: Array[Spell]

var player: Entity
var enemies: Entity
var player_energy: Array[Game.Energy]

var animation_queue: Array

func create_from_resource():
	pass

func advance_current_phase():
	current_phase += 1
	if current_phase == RoundPhase.RoundRepeats:
		current_phase = RoundPhase.Start

## Processes the current round. Returns true if NO Player input is needed to advace to the next phase
func process_current_phase() -> bool:
	match current_phase:
		RoundPhase.Start:
			return true
		RoundPhase.Movement:
			return false
		RoundPhase.Spell:
			return false
		RoundPhase.Pass:
			return true
		RoundPhase.Enemy:
			return true
		RoundPhase.End:
			return true
		RoundPhase.RoundRepeats:
			printerr("Processes unreachble phase RoundRepeats")
	return false

func advance_and_process_until_next_player_action_needed():
	while true:
		advance_current_phase()
		if not process_current_phase():
			break

func process_player_action(action):
	pass
	
