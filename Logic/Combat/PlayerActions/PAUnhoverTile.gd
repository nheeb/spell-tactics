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
	if PATileHoverUpdate.currently_hovering_drainable != null and PATileHoverUpdate.currently_hovering_drainable == tile:
		PATileHoverUpdate.open_cards_shelf_blocker.unblock()
		PATileHoverUpdate.currently_hovering_drainable.set_highlight(Highlight.Type.HoverAction, false)
		PATileHoverUpdate.on_drainable_tile_unhovered.emit(PATileHoverUpdate.currently_hovering_drainable)
		PATileHoverUpdate.currently_hovering_drainable = null

func log_me(combat: Combat, valid: bool) -> void:
	pass
