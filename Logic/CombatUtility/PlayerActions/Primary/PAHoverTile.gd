class_name PAHoverTile extends PlayerAction

var tile: Tile

static var on_tile_hovered: Signal = Utils.create_static_signal(PAHoverTile, "on_tile_hovered")
static var on_drainable_tile_hovered: Signal = Utils.create_static_signal(PAHoverTile, "on_drainable_tile_hovered")
static var on_drainable_tile_unhovered: Signal = Utils.create_static_signal(PAHoverTile, "on_drainable_tile_unhovered")

static var open_cards_shelf_blocker = Cards3D.open_hand_block.register_blocker()

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Hover Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	# maybe invalid when doing some kinds of actions, but this is fine for now
	return true

static var currently_hovering_drainable: Tile
func execute(combat: Combat) -> void:
	if combat.input.current_castable != null:
		combat.input.current_castable.get_logic()._set_preview_visuals(tile)
	# TODO ideally, move tile_hovered signals from Events into this script and bundle the logic here
	if tile.distance_to(combat.player.current_tile) <= 1 and tile.is_drainable():
		if tile != currently_hovering_drainable:
			on_drainable_tile_hovered.emit(tile)
			open_cards_shelf_blocker.block()
			if currently_hovering_drainable != null:
				on_drainable_tile_unhovered.emit(currently_hovering_drainable)
			currently_hovering_drainable = tile
	else:
		if currently_hovering_drainable != null:
			open_cards_shelf_blocker.unblock()
			on_drainable_tile_unhovered.emit(currently_hovering_drainable)
			currently_hovering_drainable = null


func on_fail(combat: Combat) -> void:
	pass
