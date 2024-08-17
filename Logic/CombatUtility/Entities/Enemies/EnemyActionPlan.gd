class_name EnemyActionPlan extends Resource

@export var enemy_ref: EntityReference
@export var action: EnemyAction
@export var target_ref: UniversalReference

var score_cache := -1.0

#####################################################
## Constructor & Getters for real combat instances ##
#####################################################

func _init(_enemy = null, _action = null, _target = null) -> void:
	if _enemy is EntityReference:
		enemy_ref = _enemy
	elif _enemy is EnemyEntity:
		enemy_ref = _enemy.get_reference()
	action = _action as EnemyAction
	if _target is UniversalReference:
		target_ref = _target
	elif _target:
		if _target.has_method("get_reference"):
			target_ref = _target.get_reference()

func get_enemy(combat: Combat) -> EnemyEntity:
	if enemy_ref:
		return enemy_ref.resolve(combat) as EnemyEntity
	return null

func get_action_logic(combat: Combat) -> EnemyActionLogic:
	if get_enemy(combat) and action:
		return get_enemy(combat).get_action_logic(action)
	return null

func get_target(combat: Combat) -> Variant:
	if target_ref:
		return target_ref.resolve(combat)
	return null

#######################
## Methods for usage ##
#######################

func execute(combat: Combat):
	get_action_logic(combat).execute(get_target(combat))

func is_possible(combat: Combat) -> bool:
	return get_action_logic(combat).is_possible(get_target(combat))

func get_evaluation_score(combat: Combat) -> float:
	if score_cache < 0.0:
		score_cache = get_action_logic(combat).evaluate(get_target(combat))\
				.get_total_score(get_enemy(combat).type.behaviour)
	return score_cache

func show_preview(combat: Combat, show: bool) -> void:
	get_action_logic(combat).show_preview(get_target(combat), show)

func get_alternative(combat: Combat) -> EnemyActionPlan:
	return get_action_logic(combat).get_alternative_plan(get_target(combat))

func get_string_action_target(combat: Combat) -> String:
	return action.pretty_name + (" -> %10s" % str(get_target(combat)) if target_ref else "")
