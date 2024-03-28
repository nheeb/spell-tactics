class_name PlayerMovement extends PlayerAction

var destination : Tile

func _init(_destination : Tile) -> void:
	destination = _destination
	action_string = "Move to %s" % destination

func is_valid(combat: Combat) -> bool:
	if combat.current_phase != Combat.RoundPhase.Movement:
		return false
	
	if destination.is_obstacle(Constants.INT64_MAX):
		return false
	
	var distance = combat.level.get_shortest_distance(combat.player.current_tile, destination)
	return distance <= combat.player.traits.movement_range

func execute(combat: Combat) -> void:
	print("Move Player to (%d, %d)" % [destination.r, destination.q])
	var path := combat.level.get_shortest_path(combat.player.current_tile, destination)
	var actual_path = []
	for tile in path:
		combat.movement.move_entity(combat.player, tile)
		actual_path.append(combat.player.current_tile)
	
	if len(actual_path) > 0:
		combat.animation.callback(combat.player.visual_entity, "start_walking")
	for tile in actual_path:
		combat.animation.callback(combat.player.visual_entity, "animation_move_to", [tile])
	if len(actual_path) > 0:
		combat.animation.callback(combat.player.visual_entity, "go_idle")
	combat.advance_and_process_until_next_player_action_needed()
