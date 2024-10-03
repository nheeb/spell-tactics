class_name Entity
## Base Class for every Object on the Tile-Grid-Level like the player, enemies or environment.


## The EntityType (Resource) this Entity is an instance of.
var type: EntityType
## ID for serializing references to the entity.
var id: EntityID
## The visual representation of this Entity optional (can be null).
## This Node is only part of the scene tree if this Entity has been added to a tile.
var visual_entity: VisualEntity
## Optional EntityLogic.
var logic: EntityLogic

## A reference to the Tile this Entity is residing on.
var current_tile: Tile
## Reference to the current combat
var combat: Combat
var energy: EnergyStack

var custom_props := {}
var status_effects : Array[StatusEffect] = []

signal entering_graveyard # Before the graveyard
signal entered_graveyard # After the graveyard

## Given the name, should this property be serialized?
const godot_internal_props = ["RefCounted", "script"]
const entity_internal_props = ["current_tile", "visual_entity", "logic", "type", "combat", "actions", "movements", "entity"]
static func should_serialize_this_prop(name: String) -> bool:
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
	
	for prop in get_property_list():
		if not Entity.should_serialize_this_prop(prop.name):
			continue
		state.entity_props[prop.name] = get(prop.name)

	if logic != null:
		for prop in logic.get_property_list():
			# TODO maybe we'll need another exclusion method for the script props
			if not Entity.should_serialize_this_prop(prop.name):
				continue
			state.script_props[prop.name] = get(prop.name)

	if visual_entity != null:
		for prop in Inspector.get_exported_properties(visual_entity):
			if not Entity.should_serialize_this_prop(prop["name"]):
				continue
			state.visual_ent_props[prop["name"]] = prop["value"]

	#print(state.entity_props)
	return state
	
func move(target: Tile):
	current_tile.remove_entity(self)
	target.add_entity(self)

## Removes the entitys energy and returns the visual DrainAnimation.
## The drained energy can be accessed only once with get_drained_energy().
func drain() -> AnimationObject:
	assert(is_drainable(), "Tried draining entity which is not drainable.")
	drained_energy = energy
	energy = EnergyStack.new([])
	return combat.animation.callback(visual_entity, "visual_drain").set_max_duration(.5)

var drained_energy: EnergyStack
## Returns an EnergyStack only if the entity was drained previously.
func get_drained_energy() -> EnergyStack:
	assert(drained_energy != null, "The entity wasn't drained before")
	var _drained_energy = drained_energy
	drained_energy = null
	return _drained_energy

## Returns true if the entity has drainable energy on it.
func is_drainable():
	return type.is_drainable and energy != null and not energy.is_empty()

## This will be executed after an entity has been created from a type.
func on_create() -> void:
	if visual_entity != null:
		visual_entity.visible = false
	else:
		push_warning("visual_entity for entity_type %s is null in on_create()" % type.internal_name)
	for status_effect in status_effects:
		status_effect.setup(self)

func get_reference() -> EntityReference:
	return EntityReference.new(self)

func is_dead() -> bool:
	return current_tile == null

## Removes the entity from the level and moves it into the graveyard.
## Returns the die animation (hiding the model for now).
func die() -> AnimationObject:
	combat.level.move_entity_to_graveyard(self)
	return combat.animation.hide(visual_entity)

## Wrapper function for the method die(). Not sure why we have this...
func go_to_graveyard() -> AnimationObject:
	return die()

func apply_status_effect(effect: StatusEffect) -> void:
	var existing_effect := get_status_effect(effect.get_status_name())
	combat.animation.say(visual_entity, effect.get_status_name()).set_duration(0.0)
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
		effect.on_remove()
		status_effects.erase(effect)


func call_on_status_effect(status_name: String, method: String, params := []) -> void:
	var effect := get_status_effect(status_name)
	if effect:
		if effect.has_method(method):
			effect.callv(method, params)
		else:
			push_error("Status effect %s has no method %s" % [status_effects, method])
			
func call_logic(method: String, params := []):
	if logic == null:
		push_error("%s does not have logic." % self)
		return
	if not logic.has_method(method):
		push_error("%s logic does not have method '%s'." % [self, method])
		return
	logic.callv(method, params)
	
func _to_string() -> String:
	if id != null:
		return type.internal_name + '_' + str(id.id)
	else:
		return type.internal_name + '_null'

func get_tags() -> Array[String]:
	return type.tags

## This takes all relevant information from the type in CombatBegin Phase.
func sync_with_type() -> void:
	energy = type.energy

func on_hover_long(h: bool) -> void:
	pass
