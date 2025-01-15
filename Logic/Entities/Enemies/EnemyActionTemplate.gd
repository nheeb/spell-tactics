class_name EnemyActionTemplate extends CombatObjectState
## Wraps an enemy action together with optional custom arguments defining
## how the action can be used by the enemy in general.

@export var action: EnemyActionType
@export var avoid := false
@export var score_factor := 1.0
@export var pre_action_template: EnemyActionTemplate = null

#@export_group("Extras")
### References to targets this action should have
#@export var fixed_targets := []

func get_template_props() -> Dictionary:
	var p := super()
	p["avoid"] = avoid
	p["score_factor"] = score_factor
	p["type"] = action
	return p

func create_enemy_actions(combat: Combat) -> Array[EnemyAction]:
	var actions: Array[EnemyAction]
	var own_action := create(combat) as EnemyAction
	assert(own_action)
	if pre_action_template:
		actions = pre_action_template.create_enemy_actions(combat)
		own_action.pre_action = actions.back()
		own_action.pre_action.selectable = false
	actions.push_back(own_action)
	return actions
