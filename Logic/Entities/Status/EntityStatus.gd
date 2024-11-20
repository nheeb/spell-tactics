class_name EntityStatus extends CombatObject

@export var type: EntityStatusType

## Internal data keys (Use the setter and getter instead)
## _lifetime -> Lifetime
## _targets -> EnemyAction - Fixed Targets

@export var is_logic_setup_done := false

var logic: EntityStatusLogic
var entity: Entity
var lifetime: int:
	set(x):
		data["_lifetime"] = x
	get:
		if not data.has("_lifetime"):
			return 0
		return data["_lifetime"]
var targets: Array:
	set(x):
		data["_targets"] = x
	get:
		if not data.has("_targets"):
			return []
		return data["_targets"]

func get_status_name() -> String:
	return type.internal_name

## Logic when status effect enters the game
## This will only be called when the status effect is applied
## not when it is loaded
func on_birth() -> void:
	if type.has_lifetime:
		TimedEffect.new_end_phase_trigger_from_callable(reduce_lifetime) \
			.set_id("_lt").set_priority(-100).register(combat)
	await super()

## Visual changes when status effect enters the game
func on_load() -> void:
	if type.make_floating_icon:
		var icon_name := "%s_icons" % get_status_name()
		combat.animation.add_staying_effect(
			VFX.ICON_VISUALS, entity.visual_entity, icon_name, \
			{"icon": type.icon, "color": type.color}
		)
	await super()

## Extend the status by another one of the same kind
func merge(other_status: EntityStatus) -> void:
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
	logic._merge(other_status)

## Effects on being removed (clean up timed effects)
func on_remove() -> void:
	# Kill TimedEffects automatically if activated
	if type.kill_te_on_remove:
		for te in combat.t_effects.get_effects(self):
			te.kill()
		for te in combat.t_effects.get_effects(logic):
			te.kill()
	# Otherwise just the lifetime
	elif type.has_lifetime:
		for te in combat.t_effects.get_effects(self, "_lt"):
			te.kill()
	# Remove floating icons
	if type.make_floating_icon:
		var icon_name := "%s_icons" % get_status_name()
		combat.animation.remove_staying_effect(entity.visual_entity, icon_name)
	logic._on_remove()

## Special actions an enemy with the status could do
func get_enemy_actions() -> Array[EnemyActionArgs]:
	var actions : Array[EnemyActionArgs] = type.enemy_actions.duplicate()
	actions.append_array(logic._get_enemy_actions())
	if targets:
		for action in actions:
			action.fixed_targets = targets
	return actions

func remove() -> void:
	logic.self_remove()

## TE
func reduce_lifetime() -> void:
	lifetime = lifetime - 1
	if lifetime < 0:
		remove()
