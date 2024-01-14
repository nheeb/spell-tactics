class_name PlayerMovement extends PlayerAction

var destination : Tile

func _init(_destination : Tile) -> void:
	destination = _destination

func is_valid() -> bool:
	if Game.combat.current_phase != Combat.RoundPhase.Movement:
		return false
	# TODO Test if destination is reachable
	return true

func execute() -> void:
	# TODO do the movement
	Game.combat.advance_and_process_until_next_player_action_needed()
