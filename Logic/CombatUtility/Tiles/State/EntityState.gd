
## Resource representing the state that should be saved for an Entity for (de-)serialization
class_name EntityState extends Resource

@export var type: EntityType

@export var entity_props: Dictionary
## props belonging to the logic script this entity might have (optional)
@export var script_props: Dictionary
## props belonging to the VisualEntity script this entity might have (optional)
@export var visual_ent_props: Dictionary


## the current tile will be set from outside, as the Tile deserialize will call this.
func deserialize(combat: Combat = null, tile : Tile = null) -> Entity:
	var entity = type.create_entity(combat, false)
	
	tile.add_entity(entity)
	
	for prop_name in entity_props.keys():
		if Entity.should_serialize_this_prop(prop_name):
			entity.set(prop_name, entity_props[prop_name])

	if entity.logic != null:
		for prop_name in script_props.keys():
			if Entity.should_serialize_this_prop(prop_name):
				entity.logic.set(prop_name, script_props[prop_name])

	if entity.visual_entity != null:
		for prop_name in visual_ent_props.keys():
			if Entity.should_serialize_this_prop(prop_name):
				entity.visual_entity.set(prop_name, visual_ent_props[prop_name])
	
	type.entity_on_create(entity, true)
	
	if entity.visual_entity != null:
		entity.visual_entity.visible = not entity.is_dead()
	
	return entity
