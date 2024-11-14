class_name Entity extends CombatObject

## Base Class for every Object on the Tile-Grid-Level like the player, 
## enemies or environment.

## The EntityType (Resource) this Entity is an instance of.
@export var type: EntityType

## The visual representation of this Entity optional (can be null).
## This Node is only part of the scene tree if this Entity has been added to a tile.
var visual_entity: VisualEntity

## Optional EntityLogic.
var logic: EntityLogic

## A reference to the Tile this Entity is residing on.
var current_tile: Tile

## Energy being held
@export var energy: EnergyStack

## list of EntityStatus
var status_array: Array[EntityStatus] = []

signal entering_graveyard # Before the graveyard
signal entered_graveyard # After the graveyard

#####################################
## Creation & CombatObject Methods ##
#####################################

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

## Write the entity into an EntityState (Resource)
func serialize() -> EntityState:
	var state: EntityState = EntityState.new(self)
	return state

func _to_string() -> String:
	if id >= 0:
		return type.internal_name + '_' + str(id)
	else:
		return type.internal_name + '_null'

func get_name() -> String:
	return "%s [%s]" % [type.pretty_name, id]

####################
## Entity Methods ##
####################

func move(target: Tile):
	current_tile.remove_entity(self)
	target.add_entity(self)

## Removes the entitys energy and returns the visual DrainAnimation.
## The drained energy can be accessed only once with get_drained_energy().
func drain() -> AnimationObject:
	assert(is_drainable(), "Tried draining entity which is not drainable.")
	drained_energy = energy
	energy = EnergyStack.new([])
	return combat.animation.call_method(visual_entity, "visual_drain").set_max_duration(.5)

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
	# TODO reimplement this
	#TimedEffect.new_combat_change(on_combat_change) \
		#.set_id("_cc").set_solo().register(combat)
	if visual_entity != null:
		visual_entity.visible = false
	else:
		push_warning("visual_entity for entity_type %s is null in on_create()" % type.internal_name)

## TE
func on_combat_change():
	pass

func is_dead() -> bool:
	return current_tile == null

## Removes the entity from the level and moves it into the graveyard.
## Returns the die animation (hiding the model for now).
func die() -> AnimationObject:
	combat.level.move_entity_to_graveyard(self)
	return combat.animation.hide(visual_entity)

func get_tags() -> Array[String]:
	return type.tags

## This takes all relevant information from the type in CombatBegin Phase.
func sync_with_type() -> void:
	energy = type.energy

## SUBACTION
func on_hover_long(h: bool) -> void:
	pass

##############################
## Methods for EntityStatus ##
##############################

## Add a status to the status_array. If a status with the same name / type is
## already in there, it gets extended instead.
func apply_status(status_or_type: Variant, additional_data := {}) -> void:
	var status: EntityStatus
	if status_or_type is EntityStatus:
		status = status_or_type
		status.data.merge(additional_data, true)
	else:
		var type := status_or_type as EntityStatusType
		assert(type)
		status = type.create_status(combat, additional_data)
	var existing_status := get_status(status.get_status_name())
	if DebugInfo.ACTIVE:
		combat.animation.say(visual_entity, status.type.pretty_name).set_duration(0.0)
	if existing_status:
		existing_status.extend(status)
	else:
		status_array.append(status)
		status.setup(self)

## Returns the status that fits given name or type.
func get_status(status_name_or_type: Variant) -> EntityStatus:
	var status_name: String
	if status_name_or_type is EntityStatusType:
		status_name = status_name_or_type.internal_name
	else:
		status_name = str(status_name_or_type)
	for status in status_array:
		if status.get_status_name().to_lower() == status_name.to_lower():
			return status
	return null

## Removes a status from the entity. To be clean use EntityStaus.remove() instead.
func remove_status(status_name_or_type: Variant) -> void:
	var status := get_status(status_name_or_type)
	if status:
		status.on_remove()
		status_array.erase(status)

#####################################################
## DEPRECATED Methods for StatusEffects DEPRECATED ##
#####################################################

#func apply_status_effect(effect: StatusEffect) -> void:
	#push_error("Using DEPRECATED StatusEffect")
	#var existing_effect := get_status_effect(effect.get_status_name())
	#if Game.DEBUG_INFO:
		#combat.animation.say(visual_entity, effect.get_status_name()).set_duration(0.0)
	#if existing_effect:
		#existing_effect.extend(effect)
	#else:
		#status_effects.append(effect)
		#effect.setup(self)
#
#func get_status_effect(status_name: String) -> StatusEffect:
	#push_error("Using DEPRECATED StatusEffect")
	#for effect in status_effects:
		#if effect.get_status_name() == status_name:
			#return effect
	#return null
#
#func remove_status_effect(status_name: String) -> void:
	#push_error("Using DEPRECATED StatusEffect")
	#var effect := get_status_effect(status_name)
	#if effect:
		#effect.on_remove()
		#status_effects.erase(effect)
