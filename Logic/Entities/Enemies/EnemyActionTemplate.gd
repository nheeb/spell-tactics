class_name EnemyActionTemplate extends CombatObjectState
## Wraps an enemy action together with optional custom arguments defining
## how the action should be used by the enemy.

@export var action: EnemyActionType
@export var score_factor := 1.0

@export_group("Avoid")
@export var try_to_avoid := false
@export var avoid_score_factor := 0.01

@export_group("Arguments")
#@export var args := [] we use data instead
#@export var kwargs := {}
## References to targets this action should have
@export var fixed_targets := []

func _init(_action: EnemyActionType = null, _args := [], _kwargs := {}) -> void:
	action = _action
	#args = _args
	#kwargs = _kwargs

#func get_arg(index: int, default = null) -> Variant:
	#default = Utility.array_safe_get(action.default_args, index, false, default)
	#return Utility.array_safe_get(args, index, false, default)
#
#func get_kwarg(key: Variant, default = null) -> Variant:
	#default = Utility.dict_safe_get(action.default_kwargs, key, default)
	#return Utility.dict_safe_get(kwargs, key, default)

#func get_temp_logic(enemy, combat) -> EnemyActionLogic:
	#if enemy and combat and action:
		#var new_action_logic = action.logic_script.new() as EnemyActionLogic
		#assert(new_action_logic, "Enemy Action Logic wasn't created.")
		#new_action_logic.args = self
		#new_action_logic.action = action
		#new_action_logic.combat = combat
		#new_action_logic.enemy = enemy
		#return new_action_logic
	#return null
