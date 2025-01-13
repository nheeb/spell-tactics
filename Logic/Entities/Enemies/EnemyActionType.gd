class_name EnemyActionType extends CombatActionType

@export_group("Target")
enum TargetType {None, Foes, Allies, Tiles, Entities}
@export var target_type : TargetType = TargetType.None
@export var can_self_target := false
@export var target_range_looking := -1
@export var target_range_walking := -1
@export_subgroup("Target Considering")
@export_range(1,8) var target_consider_count := 2
enum TargetConsiderMethod {Best}
@export var target_consider_method : TargetConsiderMethod = TargetConsiderMethod.Best

@export_group("Scores")
@export var default_scores : Array[EnemyActionCriteriaValue]

@export_group("Extras")
@export var cooldown: int = 0 # TODO implement this
@export var alternative_action_args: EnemyActionTemplate = null
@export var movement_action_args: EnemyActionTemplate = null

@export_group("Arguments")
@export var default_args: Array = []
@export var default_kwargs: Dictionary = {}
