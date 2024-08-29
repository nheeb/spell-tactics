class_name EnemyAction extends Resource

var internal_name: String = ""
@export var pretty_name: String
@export var icon: Texture
@export var color: Color = Color.WHITE

@export_group("Target")
enum TargetType {None, Foes, Allies, Tiles, Entities}
@export var target_type : TargetType = TargetType.None
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
@export var alternative_action_args: EnemyActionArgs = null
@export var movement_action_args: EnemyActionArgs = null
@export var movement_mandatory: bool = false

@export_group("Arguments")
@export var default_args: Array = []
@export var default_kwargs: Dictionary = {}

## Logic script
var logic_script: Script

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic_script = load(directory + "/" + internal_name + ".gd")
		if movement_action_args:
			assert(movement_action_args.action.movement_action_args == null,
					"Movement action has a movement action. This is cursed.")


