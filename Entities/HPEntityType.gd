@tool
class_name HPEntityType extends EntityType

@export var max_hp: int


## Overriding base entity method to return more specific type
func create_entity(combat: Combat, call_on_create := true) -> HPEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: HPEntity = HPEntity.new()
	setup_visuals_and_logic(ent, combat)
	ent.hp = max_hp
	entity_on_create(ent, call_on_create)
	return ent
