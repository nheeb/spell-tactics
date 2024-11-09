class_name TileState extends CombatObjectState

@export var r: int
@export var q: int
@export var entities: Array[EntityState]

func deserialize(combat: Combat) -> Tile:
	var n_rows := combat.level.n_rows
	var n_cols := combat.level.n_cols
	@warning_ignore("integer_division")
	var tile = Tile.create(r, q, n_rows/2 + n_rows % 1, n_cols/2 + n_cols % 1)
	#var ents: Array[Entity] = []
	var ent: Entity
	for entity_data in entities:
		ent = entity_data.deserialize(combat, tile)
		#tile.add_entity(ent)
	
	return tile
