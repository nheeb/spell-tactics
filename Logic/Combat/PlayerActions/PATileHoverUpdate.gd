class_name PATileHoverUpdate extends PlayerAction

## I still don't really understand why we use static Signals ¯\_(ツ)_/¯

static var on_tile_hovered: Signal = \
	GeneralUtilityClass.create_static_signal(PATileHoverUpdate, "on_tile_hovered")
static var on_drainable_tile_hovered: Signal = \
	GeneralUtilityClass.create_static_signal(PATileHoverUpdate, "on_drainable_tile_hovered")
static var on_drainable_tile_unhovered: Signal = \
	GeneralUtilityClass.create_static_signal(PATileHoverUpdate, "on_drainable_tile_unhovered")

static var open_cards_shelf_blocker = Cards3D.open_hand_block.register_blocker()
static var currently_hovering_drainable: Tile
static var currently_hovering_long: Tile

var tile: Tile
var hovering: bool
var long: bool

func _init(_tile: Tile, _hovering: bool, _long := false) -> void:
	tile = _tile
	hovering = _hovering
	long = _long
	action_string = "%sover Tile %s<%s>" % [
		"H" if hovering else "Unh", "Long " if long else "", tile
	]

func tile_can_be_drained(combat: Combat) -> bool:
	var drain := combat.castables.get_active_from_name("drain")
	return tile.distance_to(combat.player.current_tile) <= 1 \
		and tile.is_drainable() and drain.unlocked

func execute(combat: Combat) -> void:
	# Hover Tile
	if hovering:
		combat.level.append_to_hover_memory(tile) # This is for the movement arrow pathing
		var castable: Castable = combat.input.current_castable
		if castable:
			await castable.get_logic().set_preview_visuals(true, tile)
		if tile.distance_to(combat.player.current_tile) <= 1 and tile.is_drainable() and combat.actives[1].unlocked:
			if tile != currently_hovering_drainable:
				tile.set_highlight(Highlight.Type.HoverAction, true)
				on_drainable_tile_hovered.emit(tile)
				open_cards_shelf_blocker.block()
				if currently_hovering_drainable != null:
					currently_hovering_drainable.set_highlight(Highlight.Type.HoverAction, false)
					on_drainable_tile_unhovered.emit(currently_hovering_drainable)
				currently_hovering_drainable = tile
		else:
			if currently_hovering_drainable != null:
				open_cards_shelf_blocker.unblock()
				on_drainable_tile_unhovered.emit(currently_hovering_drainable)
				currently_hovering_drainable.set_highlight(Highlight.Type.HoverAction, false)
				currently_hovering_drainable = null
	
	# Unhover Tile
	else:
		if combat.input.current_castable != null:
			await combat.input.current_castable.get_logic().set_preview_visuals(false, tile)
		if currently_hovering_drainable != null and currently_hovering_drainable == tile:
			open_cards_shelf_blocker.unblock()
			currently_hovering_drainable.set_highlight(Highlight.Type.HoverAction, false)
			on_drainable_tile_unhovered.emit(currently_hovering_drainable)
			currently_hovering_drainable = null
