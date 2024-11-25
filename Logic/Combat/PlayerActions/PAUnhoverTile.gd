class_name PAUnhoverTile extends PlayerAction

var tile: Tile

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Unhover Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	if combat.input.current_castable != null:
		await combat.input.current_castable.get_logic().set_preview_visuals(false, tile)
	if PAHoverTile.currently_hovering_drainable != null and PAHoverTile.currently_hovering_drainable == tile:
		PAHoverTile.open_cards_shelf_blocker.unblock()
		PAHoverTile.on_drainable_tile_unhovered.emit(PAHoverTile.currently_hovering_drainable)
		PAHoverTile.currently_hovering_drainable = null

func log_me(combat: Combat, valid: bool) -> void:
	pass
