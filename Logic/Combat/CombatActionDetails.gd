class_name CombatActionDetails extends RefCounted

var actor: Entity
var combat_action: CombatAction
var target_requirements: Array[TargetRequirement]:
	get:
		return combat_action.get_action_type().target_requirements
## {TargetRequirement -> Array[Value]}
var target_details: Dictionary

#################
## Constructor ##
#################

func _init(_actor: Entity, action: CombatAction) -> void:
	actor = _actor
	if not (actor is PlayerEntity or actor is EnemyEntity):
		push_warning("Created CombatActionDetails for invalid actor.")
	combat_action = action
	for req in target_requirements:
		target_details[req] = []

#############
## Targets ##
#############

func add_targets(value: Variant):
	if are_requirements_fullfilled():
		push_warning("Target added although all requirements are fullfilled.")
		return
	var req := get_next_requirement()
	var targets := req.convert_target(value, combat_action)
	target_details[req] = targets

func remove_targets(value: Variant = null):
	if target_requirements.is_empty():
		return
	var reqs_with_value := target_requirements.filter(
		func (req: TargetRequirement):
			var targets := target_details.get(req, []) as Array
			return value in targets or value == targets
	)
	var clear_req: TargetRequirement
	if reqs_with_value.is_empty():
		clear_req = target_requirements.front()
	else:
		clear_req = reqs_with_value.front()
	for i in range(target_requirements.find(clear_req), target_requirements.size()):
		target_details[target_requirements[i]] = []

##################
## Requirements ##
##################

func get_unfullfilled_requirements() -> Array[TargetRequirement]:
	return target_requirements.filter(
		func (req: TargetRequirement):
			var targets := target_details.get(req, []) as Array
			return targets.is_empty()
	)

func get_next_requirement() -> TargetRequirement:
	if get_unfullfilled_requirements():
		return get_unfullfilled_requirements().front()
	return null

func are_requirements_fullfilled() -> bool:
	return get_unfullfilled_requirements().is_empty()

################################
## Common Getters for targets ##
################################

func get_target_array(requirement_or_index = null) -> Array:
	var requirement: TargetRequirement
	if requirement_or_index is int:
		requirement = Utility.array_safe_get(target_requirements, requirement_or_index)
	elif requirement_or_index is TargetRequirement:
		requirement = requirement_or_index
	if requirement != null:
		return target_details.get(requirement, []) as Array
	var array := []
	for req in target_requirements:
		array.append_array(target_details.get(req, []) as Array)
	return array

func get_target_tiles() -> Array[Tile]:
	var tiles: Array[Tile] = []
	for req in target_requirements:
		if req.type == TargetRequirement.Type.Tile:
			tiles.append_array(get_target_array(req))
		elif req.type == TargetRequirement.Type.EntityXX:
			tiles.append_array(get_target_array(req).map(
				func (e: Entity):
					return e.current_tile
			))
	return tiles

func get_target_tile() -> Tile:
	return Utility.array_safe_get(get_target_tiles(), 0)

func get_target_entities(exclude_terrain := true) -> Array[Entity]:
	var entities: Array[Entity] = []
	for req in target_requirements:
		if req.type == TargetRequirement.Type.Tile:
			for tile in get_target_array(req):
				if tile is Tile:
					entities.append_array(tile.entities)
		elif req.type == TargetRequirement.Type.EntityXX:
			entities.append_array(get_target_array(req))
	if exclude_terrain:
		entities = entities.filter(
			func (e: Entity):
				return not e.type.is_terrain
		)
	return entities

func get_target_entity() -> Entity:
	return Utility.array_safe_get(get_target_entities(), 0)

func get_target_enemies() -> Array[EnemyEntity]:
	var enemies: Array[EnemyEntity] = []
	enemies.append_array(get_target_entities().filter(
		func (e: Entity):
			return e is EnemyEntity
	))
	return enemies

func get_target_enemy() -> EnemyEntity:
	return Utility.array_safe_get(get_target_enemies(), 0) 
