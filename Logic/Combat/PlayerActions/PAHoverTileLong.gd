class_name PAHoverTileLong extends PlayerAction

var tile: Tile
var hover: bool

func _init(_tile: Tile, _hover: bool) -> void:
	tile = _tile
	hover = _hover
	action_string = "Hover Tile Long <%s>" % tile

func execute(combat: Combat) -> void:
	await tile._hover_long(hover)
