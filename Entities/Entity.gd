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
var logic: EntityLogic

## Reference to the Tile this Entity is residing on
var current_tile: Tile
## Reference to the current combat
var combat: Combat
var energy: EnergyStack

var custom_props := {}
var status_effects : Array[StatusEffect] = []

signal entered_graveyard

## Given the name, should this property be serialized?
const godot_internal_props = ["RefCounted", "script"]
const entity_internal_props = ["current_tile", "visual_entity", "logical_entity", "type", "combat", "actions", "movements"]
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
	
	if logic != null:
		for prop in logic.get_property_list():
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

func drain() -> EnergyStack:
	assert(is_drainable(), "Tried draining entity which is not drainable.")
	var drained_energy = energy
	energy = EnergyStack.new([])
	return drained_energy

func is_drainable():
	return type.is_drainable and energy != null and not energy.is_empty()

## This will be executed after an entity has been created from a type
func on_create() -> void:
	visual_entity.visible = false
	for status_effect in status_effects:
		status_effect.setup(self)

func get_reference() -> EntityReference:
	return EntityReference.new(self)

func is_dead() -> bool:
	return current_tile == null

func apply_status_effect(effect: StatusEffect) -> void:
	var existing_effect := get_status_effect(effect.get_status_name())
	if existing_effect:
		existing_effect.extend(effect)
	else:
		status_effects.append(effect)
		effect.setup(self)

func get_status_effect(status_name: String) -> StatusEffect:
	for effect in status_effects:
		if effect.get_status_name() == status_name:
			return effect
	return null

func remove_status_effect(status_name: String) -> void:
	var effect := get_status_effect(status_name)
	if effect:
		status_effects.erase(effect)
		effect.on_remove()

func call_on_status_effect(status_name: String, method: String, params := []) -> void:
	var effect := get_status_effect(status_name)
	if effect:
		if effect.has_method(method):
			effect.callv(method, params)
		else:
			printerr("Status effect %s has no method %s" % [status_effects, method])
			
func call_logic(method: String, params := []):
	if logic == null:
		printerr("%s does not have logic." % self)
		return
	if not logic.has_method(method):
		printerr("%s logic does not have method '%s'." % [self, method])
		return
	logic.callv(method, params)
	
func _to_string() -> String:
	return type.internal_name + '_' + str(id.id)
