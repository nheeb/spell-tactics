class_name EnemyActionLogic extends RefCounted

## This should NOT extend CombatLogic. Having a reference for this logic makes no
## sense due to it's short lifetime. Every ActionPlan (action intent) of an enemy
## creates a new Logic.

var combat: Combat
var args: EnemyActionArgs
var action: EnemyAction
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

## ACTION
func execute():
	await _execute()

## SUBRESULT
func is_possible(enemy_tile: Tile = enemy.current_tile) -> bool:
	return await _is_possible(enemy_tile)

## SUBRESULT
func evaluate(enemy_tile: Tile = enemy.current_tile) -> EnemyActionEval:
	if await is_possible(enemy_tile):
		var evaluation := EnemyActionEval.from_cv_array(action.default_scores)
		return await _evaluate(enemy_tile, evaluation)
	else:
		return EnemyActionEval.new()

## SUBRESULT
func estimated_destination(enemy_tile: Tile = enemy.current_tile) -> Tile:
	var destinaion := await _estimated_destination(enemy_tile)
	if destinaion != null:
		return destinaion
	else:
		return enemy_tile

## ACTION ANIMATOR
func show_preview(show: bool) -> void:
	await _show_preview(show)

func get_alternative_plan() -> EnemyActionPlan:
	var _plan := _get_alternative_plan()
	if _plan:
		return _plan
	elif action.alternative_action_args:
		return EnemyActionPlan.new(enemy, action.alternative_action_args, target)
	return null

func get_target_pool() -> Array:
	return _get_target_pool()

## ACTION
func setup() -> void:
	await _setup()

############################
## Methods for overriding ##
############################

## ACTION
func _execute():
	pass

## SUBRESULT
func _is_possible(enemy_tile: Tile) -> bool:
	return true

## SUBRESULT
func _evaluate(enemy_tile: Tile, eval: EnemyActionEval) -> EnemyActionEval:
	return eval

## SUBRESULT
func _estimated_destination(enemy_tile: Tile) -> Tile:
	return enemy_tile

## ACTION ANIMATOR
func _show_preview(show: bool) -> void:
	await show_movement_arrow(show)
	await show_action_icon_over_enemy(show)

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
					## FIXME This is shitty
					return t is PlayerEntity
			)
		EnemyAction.TargetType.Allies:
			all_targets = combat.get_all_hp_entities()
			all_targets = all_targets.filter(
				func (t):
					## FIXME This is shitty
					return t.team == enemy.team and t is EnemyEntity
			)
		EnemyAction.TargetType.Tiles:
			all_targets = combat.level.get_all_tiles()
		EnemyAction.TargetType.Entities:
			all_targets = combat.level.get_all_entities()
	return all_targets

## ACTION
func _setup() -> void:
	pass

####################
## Helper Methods ##
####################

## ACTION ANIMATOR
func show_movement_arrow(show: bool):
	var from: Tile = enemy.current_tile
	var to: Tile
	if plan:
		to = await combat.action_stack.get_result(
			plan.get_estimated_destination.bind(combat, from)
		)
	else:
		to = await estimated_destination(from)
		
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

## ANIMATOR
func show_action_icon_over_enemy(show: bool):
	if action.icon:
		if show:
			combat.animation.add_staying_effect(VFX.ICON_VISUALS, enemy.visual_entity, "action_icon", \
				{"icon": action.icon, "color": action.color, "quad": true}).set_flag_with()
		else:
			combat.animation.remove_staying_effect(enemy.visual_entity, "action_icon")
