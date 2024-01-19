extends AbstractPhase


func tile_clicked(tile: Tile):
	# for now try draining anytime a tile is clicked. later we'll need state,
	# whether we're targeting a spell or draining
	combat.input.process_action(PlayerDrain.new(tile))

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Cast your spells!"])
	return true
