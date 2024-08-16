class_name EnemyActionPlan extends Resource

@export var enemy_ref: EntityReference
@export var action: EnemyAction
@export var target_ref: UniversalReference

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

## TODO Nitai Cache this value
func get_evaluation_score(combat: Combat) -> float:
	return get_action_logic(combat).evaluate(get_target(combat))\
				.get_total_score(get_enemy(combat).type.behaviour)

func show_preview(combat: Combat, show: bool) -> void:
	get_action_logic(combat).show_preview(get_target(combat), show)
