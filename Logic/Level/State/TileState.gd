class_name TileState extends CombatObjectState

@export var entity_states: Array[EntityState]

func deserialize(combat: Combat) -> Tile:
	var r := props.get("r", 0) as int
	var q := props.get("q", 0) as int
	var n_rows := combat.level.n_rows
	var n_cols := combat.level.n_cols
	@warning_ignore("integer_division")
	var tile = Tile.create(r, q, n_rows/2 + n_rows % 1, n_cols/2 + n_cols % 1)
	tile.update_properties(props)
	tile.connect_with_combat(combat)
	for entity_state in entity_states:
		var ent := entity_state.deserialize(combat) as Entity
		assert(ent)
		tile.add_entity(ent)
	
	return tile
