class_name MovementPhase extends AbstractPhase

var highlighted_tiles: Array[Tile]

func tile_hovered(tile: Tile):
	pass
	
func tile_clicked(tile: Tile):
	# this was wrong (discuss maybe?):
	# PlayerMovement.new(tile).execute(combat)
	if combat.process_player_action(PlayerMovement.new(tile)):
		# valid, movement has been performed
		combat.level._unhighlight_tile_set(highlighted_tiles, Highlight.Type.Movement)

func process_phase() -> bool:
	highlighted_tiles = combat.level.highlight_movement_range(combat.player, combat.player.traits.movement_range)
	combat.animation.callback(combat.ui, "set_status", ["Make your movement!"])
	
	return true
