class_name MovementPhase extends AbstractPhase

var highlighted_tiles: Array[Tile]

func tile_hovered(tile: Tile):
	pass
	
func tile_clicked(tile: Tile):
	if combat.input.process_action(PlayerMovement.new(tile)):
		# valid, movement has been performed
		combat.level._unhighlight_tile_set(combat.level.get_all_tiles(), Highlight.Type.Movement)

func process_phase() -> bool:
	combat.animation.callback(combat.level, "highlight_movement_range", [combat.player, combat.player.traits.movement_range])
	combat.animation.callback(combat.ui, "set_status", ["Make your movement!"])
	
	# unlock all actives that are available once per round
	for active in combat.actives:
		if active.type.limitation == ActiveType.Limitation.X_PER_ROUND:
			active.unlocked = true
			active.uses_left = max(active.uses_left, active.type.max_uses_per_round)
		# check active unlocked conditions
	
	return true
