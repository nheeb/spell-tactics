@tool
class_name Entity

## The EntityType (Resource) this Entity is an instance of
var type: EntityType
## ID for serializing references to the entity
var id: EntityID
## The visual representation of this Entity optional (can be null).
## This Node is only part of the scene tree if this Entity has been added to a tile.
var visual_entity: VisualEntity
## optional:
var logical_entity: LogicalEntity

## Reference to the Tile this Entity is residing on
var current_tile: Tile
## Reference to the current combat
var combat: Combat
var energy: Array[Game.Energy]

## Given the name, should this property be serialized?
const godot_internal_props = ["RefCounted", "script"]
const entity_internal_props = ["current_tile", "visual_entity", "logical_entity", "type", "combat", "actions", "movements", "forced_actions", "forced_movements"]
static func serialize_this_prop(name: String) -> bool:
	if name.ends_with(".gd"):
		# script type, ignore this
		return false
	if name in godot_internal_props or name in entity_internal_props:
		return false
	return true

func serialize() -> EntityState:
	#print("-- Serializing %s --" % type.internal_name)
	var state: EntityState = EntityState.new()
	state.type = type
	
	if logical_entity != null:
		for prop in logical_entity.get_property_list():
			# TODO maybe we'll need another exclusion method for the script props
			if not Entity.serialize_this_prop(prop.name):
				continue
			state.script_props[prop.name] = get(prop.name)
	
	for prop in get_property_list():
		if not Entity.serialize_this_prop(prop.name):
			continue
		state.entity_props[prop.name] = get(prop.name)

	#print(state.entity_props)
	return state
	
func move(target: Tile):
	current_tile.remove_entity(self)
	target.add_entity(self)
	
func drain() -> Array[Game.Energy]:
	assert(is_drainable(), "Tried draining entity which is not drainable.")
	var drained_energy = Array(energy)
	energy = []
	return drained_energy
	
func is_drainable():
	return type.is_drainable and len(energy) > 0

## This will be executed after an entity has been created from a type
func on_create() -> void:
	pass

func get_reference() -> EntityReference:
	return EntityReference.new(self)
