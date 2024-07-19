class_name PAHoverTile extends PlayerAction

var tile: Tile

static var on_tile_hovered: Signal = Utils.create_static_signal(PAHoverTile, "on_tile_hovered")
static var on_drainable_tile_hovered: Signal = Utils.create_static_signal(PAHoverTile, "on_drainable_tile_hovered")

static var on_drainable_tile_unhovered: Signal = Utils.create_static_signal(PAHoverTile, "on_drainable_tile_hovered")

func _init(_tile: Tile) -> void:
	tile = _tile
	action_string = "Hover Tile <%s>" % tile

func is_valid(combat: Combat) -> bool:
	# maybe invalid when doing some kinds of actions, but this is fine for now
	return true

	
	

var currently_draining: Tile = tile
func execute(combat: Combat) -> void:
	# TODO ideally, move tile_hovered signals from Events into this script and bundle the logic here
	if tile.distance_to(combat.player.current_tile) <= 1:
		on_drainable_tile_hovered.emit(tile)


func on_fail(combat: Combat) -> void:
	pass

