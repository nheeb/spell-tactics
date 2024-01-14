class_name TileGridHelper extends Object


enum GridDirection {
	West,
	NorthWest,
	NorthEast,
	East,
	SouthEast,
	SouthWest
}

static var all_directions = [
	GridDirection.West,
	GridDirection.NorthWest,
	GridDirection.NorthEast,
	GridDirection.East,
	GridDirection.SouthEast,
	GridDirection.SouthWest
]

static func get_direction_offset(direction: GridDirection) -> Vector2i:
	if direction == GridDirection.East:
		return Vector2i(1, 0)
	if direction == GridDirection.West:
		return Vector2i(-1, 0)
	if direction == GridDirection.NorthWest:
		return Vector2i(0, -1)
	if direction == GridDirection.SouthEast:
		return Vector2i(0, 1)
	if direction == GridDirection.NorthEast:
		return Vector2i(1, -1)
	if direction == GridDirection.SouthWest:
		return Vector2i(-1, 1)
	return Vector2i.ZERO
