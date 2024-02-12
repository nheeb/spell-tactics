class_name TileReference extends UniversalReference

@export var location: Vector2i

var tile: Tile

func _init(_location: Vector2i = Vector2i.ZERO) -> void:
	location = _location

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	tile = combat.level.get_tile_by_location(location)

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return tile

func get_reference_type() -> String:
	return "TileReference"
