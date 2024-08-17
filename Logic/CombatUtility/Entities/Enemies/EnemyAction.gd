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
@export var cooldown := 0 # TODO implement this
@export var alternative_action: EnemyAction = null
@export var movement_action: EnemyAction = null
@export var movement_mandatory := false

## Logic script
var logic_script: Script

static func load_from_file(path: String) -> CastableType:
	var res = load(path)
	if res == null:
		push_error("Castable could not be loaded. Path is %s" % path)
	res._on_load()
	return res

func _on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		logic_script = load(directory + "/" + internal_name + ".gd")
		if movement_action:
			assert(movement_action.movement_action == null,
					"Movement action has a movement action. This is cursed.")

func get_possible_plans(enemy: EnemyEntity) -> Array[EnemyActionPlan]:
	var combat := enemy.combat
	var all_targets := []
	match target_type:
		TargetType.None:
			return [EnemyActionPlan.new(enemy, self)]
		TargetType.Foes:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team != enemy.team
			)
		TargetType.Allies:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team == enemy.team
			)
		TargetType.Tiles:
			all_targets = combat.level.get_all_tiles()
		TargetType.Entities:
			all_targets = combat.level.get_all_entities()

	var suitable_targets := []
	var enemy_tile = enemy.current_tile
	for target in all_targets:
		var target_tile: Tile
		if target is Tile:
			target_tile = target
		elif target is Entity:
			target_tile = target.current_tile
		if target_tile:
			if target_range_looking != -1:
				if enemy_tile.distance_to(target_tile) > target_range_looking:
					continue
			if target_range_walking != -1:
				if combat.level.get_shortest_distance(enemy_tile, target_tile) > target_range_walking:
					continue
		if enemy.get_action_logic(self).is_possible(target):
			suitable_targets.append(target)
	var plans : Array[EnemyActionPlan] = []
	for suitable_target in suitable_targets:
		plans.append(EnemyActionPlan.new(enemy, self, suitable_target))
	if target_consider_method == TargetConsiderMethod.Best:
		plans.sort_custom(
			func (a, b):
				return a.get_evaluation_score() > b.get_evaluation_score()
		)
		plans = plans.slice(0, target_consider_count)
	return plans
