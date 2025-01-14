class_name EnemyActionTemplate extends CombatObjectState
## Wraps an enemy action together with optional custom arguments defining
## how the action can be used by the enemy in general.

@export var action: EnemyActionType
@export var try_to_avoid := false

@export_group("Score Factors")
@export var score_factor := 1.0
@export var avoid_score_factor := 0.01

#@export_group("Extras")
### References to targets this action should have
#@export var fixed_targets := []

func get_template_props() -> Dictionary:
	var p := super()
	p["try_to_avoid"] = try_to_avoid
	p["score_factor"] = score_factor
	p["avoid_score_factor"] = avoid_score_factor
	p["type"] = action
	return p

func create_enemy_action(combat: Combat) -> EnemyAction:
	return create(combat) as EnemyAction
