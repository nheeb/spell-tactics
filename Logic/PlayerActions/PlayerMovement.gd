class_name PlayerMovement extends PlayerAction

var destination : Tile

func _init(_destination : Tile) -> void:
	destination = _destination
	action_string = "Move to %s" % destination

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Movement:
		return false
	
	var distance = combat.level.tile_distance(combat.player.current_tile, destination)
	return distance <= combat.player.traits.movement_range

func execute(combat: Combat) -> void:
	print("Move Player to (%d, %d)" % [destination.r, destination.q])
	combat.movement.move_entity(combat.player, destination)
	combat.advance_and_process_until_next_player_action_needed()
