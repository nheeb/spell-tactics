@tool
## Resource representing the state that should be saved for an Entity for (de-)serialization
class_name EntityState extends Resource

@export var type: EntityType

@export var entity_props: Dictionary
## props belonging to the logic script this entity might have (optional)
@export var script_props: Dictionary


## the current tile will be set from outside, as the Tile deserialize will call this.
func deserialize(combat: Combat) -> Entity:
	var entity = type.create_entity(combat)
	
	for prop_name in entity_props.keys():
		entity.set(prop_name, entity_props[prop_name])
	
	if entity.logical_entity != null:
		for prop_name in script_props.keys():
			entity.logical_entity.set(prop_name, script_props[prop_name])
	
	entity.visual_entity.visible = true
	
	return entity
