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

func tile_can_interact(combat: Combat) -> bool:
	return tile.distance_to(combat.player.current_tile) <= 1 \
		and tile.entities.any(func (ent: Entity): return ent.can_interact)

func get_highlight_type(combat: Combat) -> Highlight.Type:
	if combat.input.current_castable != null \
		and combat.input.current_castable.get_type() == Preloaded.ACTIVE_MOVEMENT:
	#if combat.input.current_castable != null \
		#and "Movement" in combat.input.current_castable.get_type().pretty_name:
		return Highlight.Type.HoverAction
	elif combat.input.current_castable != null:
		return Highlight.Type.HoverTarget
	else:
		return Highlight.Type.Hover

func execute(combat: Combat) -> void:
	combat.animation.record_start("hover")
	
	# Hover Tile
	if hovering:
		combat.level.append_to_hover_memory(tile) # This is for the movement arrow pathing
		tile.set_highlight(get_highlight_type(combat), true)
		if tile_can_interact(combat):
			tile.set_highlight(Highlight.Type.HoverInteract, true)
		if tile_can_be_drained(combat):
			if tile != currently_hovering_drainable:
				currently_hovering_drainable = tile
				tile.set_highlight(Highlight.Type.HoverAction, true)
				on_drainable_tile_hovered.emit(tile)
				open_cards_shelf_blocker.block()
	# Unhover Tile
	else:
		tile.set_highlight(Highlight.Type.Hover, false)
		tile.set_highlight(Highlight.Type.HoverTarget, false)
		tile.set_highlight(Highlight.Type.HoverAction, false)
		tile.set_highlight(Highlight.Type.HoverInteract, false)
		if currently_hovering_drainable == tile:
			open_cards_shelf_blocker.unblock()
			on_drainable_tile_unhovered.emit(currently_hovering_drainable)
			currently_hovering_drainable = null
	
	# Castable Visual Preview
	if combat.input.current_castable != null:
		await combat.input.current_castable.get_logic().set_preview_visuals(hovering, tile)
	
	# Hover Long
	if long:
		if hovering:
			currently_hovering_long = tile
		else:
			currently_hovering_long = null
		await tile.hover_long(hovering)
	elif currently_hovering_long != tile and currently_hovering_long != null:
		await currently_hovering_long.hover_long(false)
		currently_hovering_long = null

	combat.animation.record_finish_as_subqueue("hover").seperate_queue("hover")
