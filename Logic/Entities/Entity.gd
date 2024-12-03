class_name Entity extends CombatObject

## Base Class for every Object on the Tile-Grid-Level like the player, 
## enemies or environment.

## The EntityType (Resource) this Entity is an instance of.
@export var type: EntityType

## The visual representation of this Entity optional (can be null).
## This Node is only part of the scene tree if this Entity has been added to a tile.
var visual_entity: VisualEntity:
	set(x):
		node3d = x
	get:
		return node3d as VisualEntity

## Optional EntityLogic.
var logic: EntityLogic

## A reference to the Tile this Entity is residing on.
var current_tile: Tile

## Energy being held
@export var energy: EnergyStack
## Current hp if destructable
@export var hp: int
## Max hp
@export var max_hp: int
## Armor as addition to hp
@export var armor: int
## Team when it comes to enemy targetting
@export var team: EntityType.Teams
## Value for size or height when it comes to taking damage being applied to a tile
@export var cover: int


## List of EntityStatus
var status_array: Array[EntityStatus] = []

signal entering_graveyard # Before the graveyard
signal entered_graveyard # After the graveyard

#####################################
## Creation & CombatObject Methods ##
#####################################

## Write the entity into an EntityState (Resource)
func serialize() -> EntityState:
	var state: EntityState = EntityState.new(self)
	return state

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

func get_tags() -> Array[String]:
	return type.tags

## ACTION
func on_hover_long(h: bool) -> void:
	if (not type.always_show_hp) and visual_entity.health_bar:
		if h:
			combat.animation.show(visual_entity.health_bar)
		else:
			combat.animation.hide(visual_entity.health_bar)

############################
## CombatObject Overrides ##
############################

var pre_death_tile: Tile

## Removes the entity from the level and moves it into the graveyard.
## Returns the die animation (hiding the model for now).
func die():
	pre_death_tile = current_tile
	combat.level.move_entity_to_graveyard(self)
	combat.animation.hide(visual_entity)
	await super()

func on_death():
	combat.animation.call_method(visual_entity, "on_death_visuals")
	await super()
	assert(pre_death_tile)
	if type.corpse_state:
		var corpse := type.corpse_state.deserialize_on_tile(pre_death_tile)
		combat.animation.effect(VFX.HEX_RINGS, pre_death_tile, {"color": corpse.type.color})

func on_birth():
	await super()
	if type.has_hp:
		TimedEffect.new_combat_change(check_hp) \
			.set_id("_cc_check_hp").set_solo().register(combat)

## This will be executed after an entity has been created from a type.
func on_load() -> void:
	await super()
	#if visual_entity != null:
		#visual_entity.visible = false
	#else:
		#push_warning("visual_entity for entity_type %s is null in on_load()" % type.internal_name)

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
		var status_type := status_or_type as EntityStatusType
		assert(status_type)
		status = status_type.create_status(combat, self, additional_data)
	if DebugInfo.ACTIVE:
		combat.animation.say(visual_entity, status.type.pretty_name).set_duration(0.0)
	var existing_status := get_status(status.get_name())
	if existing_status and status.type.merge_this_type:
		existing_status.front().merge(status)
	else:
		status_array.append(status)
		#status.setup(self)

## Returns the status that fits given name or type.
func get_status(status_name_or_type: Variant) -> Array[EntityStatus]:
	var all_status: Array[EntityStatus] = []
	var status_name: String
	if status_name_or_type is EntityStatusType:
		status_name = status_name_or_type.internal_name
	else:
		status_name = str(status_name_or_type)
	for status in status_array:
		if status.get_name().to_lower() == status_name.to_lower():
			all_status.append(status)
	return all_status

## Removes a status from the entity.
func remove_status(status_or_name_or_type: Variant) -> void:
	var to_be_removed: Array[EntityStatus] = []
	if status_or_name_or_type is EntityStatus:
		to_be_removed = [status_or_name_or_type]
	else:
		to_be_removed = get_status(status_or_name_or_type)
	for status in to_be_removed:
		if not status in status_array:
			push_warning("Remove status got a status which is not on the entity.")
			continue
		if status.dead:
			push_warning("Trying to kill a dead status")
			continue
		combat.action_stack.push_before_active(status.die)
	await combat.action_stack.wait()

func _erase_status(status: EntityStatus) -> void:
	if not status.dead:
		push_warning("Status should be dead when getting erased.")
	if not status in status_array:
		push_warning("Erase status got a status which is not on the entity.")
	status_array.erase(status)

################
## HP Related ##
################

func inflict_damage(damage: int):
	if damage <= 0:
		return
	var new_armor = max(0, armor - damage)
	damage -= armor
	armor = new_armor
	if damage <= 0:
		return
	hp = hp - damage

func inflict_damage_with_visuals(damage: int, with_text := false) -> AnimationObject:
	inflict_damage(damage)
	var animations = []
	animations.append(combat.animation.update_hp(self))
	animations.append(combat.animation.call_method(visual_entity, "on_hurt_visuals"))
	if with_text:
		animations.append(combat.animation.say(self.visual_entity, "%s Damage" % damage,\
		 		{"color": Color.RED, "font_size": 64}).set_duration(.5).set_flag_with())
	
	return combat.animation.reappend_as_subqueue(animations)

func inflict_heal_with_visuals(heal: int) -> AnimationObject:
	type = type as EntityType
	hp = min(type.max_hp, hp + heal)
	return combat.animation.update_hp(self)

func is_wounded() -> bool:
	return hp < type.max_hp 

## TE
func check_hp():
	if hp <= 0:
		await combat.action_stack.process_callable(die)
