
class_name TileState extends Resource

@export var r: int
@export var q: int
@export var entities: Array[EntityState]

func deserialize(combat: Combat, n_rows: int, n_cols: int) -> Tile:
	@warning_ignore("integer_division")
	var tile = Tile.create(r, q, n_rows/2 + n_rows % 1, n_cols/2 + n_cols % 1)
	#var ents: Array[Entity] = []
	var ent: Entity
	for entity_data in entities:
		ent = entity_data.deserialize(combat, tile)
		#tile.add_entity(ent)
	
	return tile
