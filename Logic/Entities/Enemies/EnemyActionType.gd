class_name EnemyActionType extends CombatActionType

@export_group("Target Considering")
@export_range(1,8) var target_consider_count := 2
enum TargetConsiderMethod {Best, Random}
@export var target_consider_method : TargetConsiderMethod = TargetConsiderMethod.Best

@export_group("Scores")
@export var default_scores : Array[EnemyActionCriteriaValue]

@export_group("Extras")
@export var cooldown: int = 0
