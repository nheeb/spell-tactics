class_name EntityStatus extends Resource

@export var type: EntityStatusType
@export var data := {}
@export var is_logic_setup_done := false

var logic: EntityStatusLogic
var entity: Entity:
	get:
		return logic.entity
var combat: Combat:
	get:
		return logic.combat
var lifetime: int:
	set(x):
		data["_lifetime"] = x
	get:
		if not data.has("_lifetime"):
			push_error("Illegal access of lifetime on status")
			return 0
		return data["_lifetime"]

func _init(_type: EntityStatusType = null, _data := {}) -> void:
	type = _type
	if type:
		# Build data
		data.clear()
		if type.has_lifetime:
			lifetime = type.lifetime_default # Uses data in the setter
		data.merge(type.default_data, true)
		data.merge(_data, true)

func setup(_entity: Entity):
	# Create Logic Object
	logic = type.create_logic()
	logic.entity = _entity
	logic.combat = _entity.combat
	logic.status = self
	# Execute Setup
	if not is_logic_setup_done:
		logic._setup_logic()
		is_logic_setup_done = true
	logic._setup_visually()

func get_status_name() -> String:
	return type.internal_name

## Logic when status effect enters the game
## This will only be called when the status effect is applied
## not when it is loaded
func setup_logic() -> void:
	if type.has_lifetime:
		TimedEffect.new_end_phase_trigger_from_callable(reduce_lifetime) \
			.set_owner(self).set_id("lifetime").register(combat)
	logic._setup_logic()

## Visual changes when status effect enters the game
func setup_visually() -> void:
	if type.make_floating_icon:
		var id := "%s_icons" % get_status_name()
		combat.animation.add_staying_effect(
			VFX.ICON_VISUALS, entity.visual_entity, id, \
			{"icon": type.icon, "color": type.color}
		)
	logic._setup_visually()

## Extend the status by another one of the same kind
func extend(other_status: EntityStatus) -> void:
	if type.has_lifetime:
		match type.lifetime_extend_method:
			0: # max
				lifetime = max(lifetime, other_status.lifetime)
			1: # sum
				lifetime = lifetime + other_status.lifetime
			2: # reset
				lifetime = other_status.lifetime
			3: # ignore
				pass
	logic._extend(other_status)

## Effects on being removed (clean up timed effects)
func on_remove() -> void:
	if type.make_floating_icon:
		var id := "%s_icons" % get_status_name()
		combat.animation.remove_staying_effect(entity.visual_entity, id)
	logic._on_remove()

## Special actions an enemy with the status could do
func get_enemy_actions() -> Array[EnemyActionArgs]:
	var actions := type.enemy_actions.duplicate()
	actions.append_array(logic._get_enemy_actions())
	return actions

func remove() -> void:
	for te in combat.t_effects.get_effects(self, "lifetime"):
		te.kill()
	logic.self_remove()

func reduce_lifetime() -> void:
	lifetime = lifetime - 1
	if lifetime <= 0:
		remove()

func get_reference() -> EntityStatusReference:
	return EntityStatusReference.new(entity.get_reference(), get_status_name())
