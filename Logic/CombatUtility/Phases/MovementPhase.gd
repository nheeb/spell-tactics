class_name MovementPhase extends AbstractPhase

var highlighted_tiles: Array[Tile]

func tile_hovered(tile: Tile):
	var path = combat.level.get_shortest_path(combat.player.current_tile, tile)
	if len(path) > 0 and not combat.animation.is_playing():
		var positions : Array[Vector3] = [combat.player.current_tile.global_position]
		for t in path:
			positions.append(t.global_position)
		combat.level.immediate_arrows().render_path(positions)
	
func tile_clicked(tile: Tile):
	if combat.input.process_action(PlayerMovement.new(tile)):
		# valid, movement has been performed
		combat.level._unhighlight_tile_set(combat.level.get_all_tiles(), Highlight.Type.Movement)
		combat.level.immediate_arrows().clear()

func process_phase() -> bool:
	combat.animation.callback(combat.level, "highlight_movement_range", [combat.player, combat.player.traits.movement_range])
	combat.animation.callback(combat.ui, "set_status", ["Make your movement!"])
	
	return true
