class_name EnemyActionLogic extends Object

var args: EnemyActionArgs
var action: EnemyAction
var combat: Combat
var enemy: EnemyEntity
var plan: EnemyActionPlan
var target:
	get:
		if target:
			return target
		if combat and plan:
			return plan.get_target(combat)
		return null
var target_tile: Tile:
	get:
		if target is Tile:
			return target
		elif target is Entity:
			return target.current_tile
		else:
			return null
var target_entity: Entity:
	get:
		if target is Entity:
			return target
		else:
			return null

#########################
## Methods for calling ##
#########################

func execute():
	await _execute()

func is_possible(enemy_tile: Tile = enemy.current_tile) -> bool:
	return _is_possible(enemy_tile)

func evaluate(enemy_tile: Tile = enemy.current_tile) -> EnemyActionEval:
	if is_possible(enemy_tile):
		var evaluation := _evaluate(enemy_tile)
		if evaluation == null:
			evaluation = EnemyActionEval.from_cv_array(action.default_scores)
		return evaluation
	else:
		return EnemyActionEval.new()

func estimated_destination(enemy_tile: Tile = enemy.current_tile) -> Tile:
	var destinaion := _estimated_destination(enemy_tile)
	if destinaion != null:
		return destinaion
	else:
		return enemy_tile

func show_preview(show: bool) -> void:
	_show_preview(show)

func get_alternative_plan() -> EnemyActionPlan:
	var _plan := _get_alternative_plan()
	if _plan:
		return _plan
	elif action.alternative_action_args:
		return EnemyActionPlan.new(enemy, action.alternative_action_args, target)
	return null

func get_target_pool() -> Array:
	return _get_target_pool()

func setup() -> void:
	_setup()

############################
## Methods for overriding ##
############################

func _execute():
	pass

func _is_possible(enemy_tile: Tile) -> bool:
	return true

func _evaluate(enemy_tile: Tile) -> EnemyActionEval:
	return null

func _estimated_destination(enemy_tile: Tile) -> Tile:
	return enemy_tile

func _show_preview(show: bool) -> void:
	show_movement_arrow(show)
	show_action_icon_over_enemy(show)

func _get_alternative_plan() -> EnemyActionPlan:
	return null

func _get_target_pool() -> Array:
	var all_targets := []
	match action.target_type:
		EnemyAction.TargetType.None:
			return [null]
		EnemyAction.TargetType.Foes:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team != enemy.team
			)
		EnemyAction.TargetType.Allies:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					return t.team == enemy.team
			)
		EnemyAction.TargetType.Tiles:
			all_targets = combat.level.get_all_tiles()
		EnemyAction.TargetType.Entities:
			all_targets = combat.level.get_all_entities()
	return all_targets

func _setup() -> void:
	pass

####################
## Helper Methods ##
####################

func show_movement_arrow(show: bool):
	var from: Tile = enemy.current_tile
	var to: Tile
	if plan:
		var dest := combat.action_stack.process_result(
			plan.get_estimated_destination.bind(combat, from)
		)
		await dest.resolved
		to = dest.value
	else:
		to = estimated_destination(from)
		
	if from != to:
		if show:
			var path: Array[Vector3] = [enemy.visual_entity.global_position]
			path.append_array(combat.level.get_shortest_path(from, to).map(
				func (t):
					return t.global_position
			))
			combat.animation.callable(
				combat.level.immediate_arrows().render_path.bind(path)
			)
		else:
			combat.animation.callable(combat.level.immediate_arrows().clear)

func show_action_icon_over_enemy(show: bool):
	if action.icon:
		if show:
			combat.animation.add_staying_effect(VFX.ICON_VISUALS, enemy.visual_entity, "action_icon", \
				{"icon": action.icon, "color": action.color, "quad": true})
		else:
			combat.animation.remove_staying_effect(enemy.visual_entity, "action_icon")
