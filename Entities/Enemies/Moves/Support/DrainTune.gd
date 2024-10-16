extends EnemyActionLogic

func get_top_energy_tiles(origin: Tile, _range := 1, count := -1) -> Array[Tile]:
	var surrounding := origin.get_surrounding_tiles(_range)
	var drainable := surrounding.filter(
		func (t: Tile):
			return t.is_drainable()
	)
	drainable.sort_custom(
		func (a: Tile, b: Tile):
			return a.get_drainable_energy().size() >= b.get_drainable_energy().size()
	)
	if count > 0:
		return drainable.slice(0, count)
	else:
		return drainable

func _execute():
	pass
