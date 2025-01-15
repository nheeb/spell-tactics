class_name CombatActionDetails extends RefCounted
## This is the situational HOW of the Action's execution. Most important here are the
## actor entity and the targets.

## Entity that will execute the Action. If the Action is a castable, this will be the Player.
var actor: Entity
## Reference to the action
var combat_action: CombatAction
## This is a duplicate of the ActionType's target reqs
var target_requirements: Array[TargetRequirement]
## Selected targets for the Action based on TargetRequirements
## {TargetRequirement -> Array[Value]}
var target_objects: Dictionary
## This is tile from which the actor executes the action. By default this is
## the actors current_tile. Only when Enemies calculate ahead this may differ.
var origin_tile: Tile

#################
## Constructor ##
#################

func _init(_actor: Entity, action: CombatAction, targets: Array = []) -> void:
	actor = _actor
	origin_tile = actor.current_tile
	if not (actor is PlayerEntity or actor is EnemyEntity):
		push_warning("Created CombatActionDetails for invalid actor.")
	combat_action = action
	target_requirements = combat_action.get_action_type().target_requirements
	for req in target_requirements:
		target_objects[req] = []
	for t in targets:
		add_targets(t)

#############
## Targets ##
#############

func add_targets(value: Variant):
	if are_requirements_fullfilled():
		push_warning("Target added although all requirements are fullfilled.")
		return
	var req := get_next_requirement()
	var targets := req.convert_target(value, self)
	target_objects[req] = targets

func remove_targets(value: Variant = null):
	if target_requirements.is_empty():
		return
	var reqs_with_value := target_requirements.filter(
		func (req: TargetRequirement):
			var targets := target_objects.get(req, []) as Array
			return value in targets or value == targets
	)
	var clear_req: TargetRequirement
	if reqs_with_value.is_empty():
		clear_req = target_requirements.front()
	else:
		clear_req = reqs_with_value.front()
	for i in range(target_requirements.find(clear_req), target_requirements.size()):
		target_objects[target_requirements[i]] = []

##################
## Requirements ##
##################

func get_unfullfilled_requirements() -> Array[TargetRequirement]:
	return target_requirements.filter(
		func (req: TargetRequirement):
			var targets := target_objects.get(req, []) as Array
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
		return target_objects.get(requirement, []) as Array
	var array := []
	for req in target_requirements:
		array.append_array(target_objects.get(req, []) as Array)
	return array

func get_target_tiles() -> Array[Tile]:
	var tiles: Array[Tile] = []
	for req in target_requirements:
		if req.type == TargetRequirement.Type.Tile:
			tiles.append_array(get_target_array(req))
		elif req.type == TargetRequirement.Type.Entity:
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
		elif req.type == TargetRequirement.Type.Entity:
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
