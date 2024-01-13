## Resource representing the state that should be saved for an Entity for (de-)serialization
class_name EntityState extends Resource

@export var type: EntityType
@export var entity_props: Dictionary
## props belonging to the logic script this entity might have (optional)
@export var script_props: Dictionary





func to_entity() -> Entity:
	# TODO
	return null
