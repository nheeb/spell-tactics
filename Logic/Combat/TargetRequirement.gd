class_name TargetRequirement extends Resource

enum Type {
	Tile,
	EntityXX,
	SpellXX,
	EnergyStackXX
}

## Type of the target object / objects
@export var type: Type

enum Limitation {
	## Only Tiles without obstacle can be selected
	NoBlocker = 1,
	## Only Tiles with an enemy can be selected
	Enemy = 2,
	## Only Tiles with entity with target_tag can be selected
	EntityWithTag = 4,
	## Terrain will not be removed from the targets
	IncludeTerrain = 8
}

## Common limitations for the selectable targets
@export_flags(
	"No Blocker / Obstacle:1",
	"Enemy:2",
	"Entity with special Tag:4",
	"Include Terrain:8"
) var limitation: int

enum RangeSize {
	UNLIMITED = 0,
	ADJACENT = 1,
	SHORT = 2,
	MEDIUM = 4,
	LONG = 6,
	EXTREME = 8,
}

## Max distance between actor and targets
@export var range_size: RangeSize

enum Shape {
	None,
	Cone,
	Circle,
}

@export_group("Extras")
@export var mandatory := true
@export var target_tag := ""
@export var shape_select: Shape
@export var shape_size := 1

@export_group("Visuals")
@export var help_text := "Target"
@export var possible_highlight: Highlight.Type = Highlight.Type.PossibleTarget
@export var selected_highlight: Highlight.Type = Highlight.Type.SelectedTarget

##########################
## Possible Target Pool ##
##########################

func get_possible_targets(action: CombatAction, actor: Entity) -> Array:
	return convert_target(get_base_pool(action.combat), action, actor)

func get_base_pool(combat: Combat) -> Array:
	match type:
		Type.Tile:
			return combat.level.tiles.duplicate()
	return []

####################################
## Filtering / Converting targets ##
####################################

## Takes a single / array of targets and converts them to whatever might suit the requirement.
## If the target is invalid it returns an empty array.
func convert_target(target: Variant, action: CombatAction = null, actor: Entity = null) -> Array:
	if action:
		if actor == null and action.details != null:
			actor = action.details.actor
	if target == null or target == []:
		return []
	var targets := Utility.array_from(target)
	targets = convert_targets_based_on_type(targets)
	targets = filter_null_and_duplicates(targets)
	targets = filter_based_on_limitation(targets)
	if actor:
		targets = filter_based_on_range(targets, actor)
		if action:
			targets = filter_based_on_action_logic(targets, actor, action)
	return targets

func convert_targets_based_on_type(targets: Array) -> Array:
	var converted_targets := []
	for target in targets:
		match type:
			Type.Tile:
				if target is Entity:
					converted_targets.append(target.current_tile)
				else:
					converted_targets.append(target as Tile)
			Type.EntityXX:
				if target is Tile:
					converted_targets.append_array(target.entities)
				converted_targets.append(target as Entity)
			Type.SpellXX:
				converted_targets.append(target as Spell)
			Type.EnergyStackXX:
				converted_targets.append(target as EnergyStack)
	return converted_targets

func filter_null_and_duplicates(array: Array) -> Array:
	var no_null := array.filter(
		func (t):
			return t != null
	)
	var result := []
	while not no_null.is_empty():
		var t = no_null.pop_front()
		if not t in no_null:
			result.append(t)
	return result

func filter_based_on_limitation(targets: Array) -> Array:
	# Filter tiles with blocker
	if Utility.has_int_flag(limitation, Limitation.NoBlocker):
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return not t.is_blocked()
					return true
			)
	
	# Filter tiles with no enemies
	if Utility.has_int_flag(limitation, Limitation.Enemy):
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return t.entities.any(
							func (e: Entity):
								return e is EnemyEntity
						)
					return true
			)
		elif type == Type.EntityXX:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return t is EnemyEntity
					return true
			)
	
	# Filter tiles with no target_tag
	if Utility.has_int_flag(limitation, Limitation.EntityWithTag):
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return t.entities.any(
							func (e: Entity):
								return target_tag in e.type.tags
						)
					return true
			)
		elif type == Type.EntityXX:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return target_tag in t.type.tags
					return true
			)
	
	# If not include terrain, exclude it
	if not Utility.has_int_flag(limitation, Limitation.IncludeTerrain):
		if type == Type.EntityXX:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return not t.type.is_terrain
					return true
			)
	
	return targets

func filter_based_on_range(targets: Array, actor: Entity) -> Array:
	if range_size == RangeSize.UNLIMITED:
		return targets
	return targets.filter(
		func (t):
			var tile := t as Tile
			if t is Entity:
				tile = t.current_tile
			if tile == null:
				return true
			return tile.distance_to(actor.current_tile) <= int(range_size)
	)

func filter_based_on_action_logic(targets: Array, actor: Entity, action: CombatAction) -> Array:
	return targets.filter(
		func (t: Variant):
			return action.get_action_logic().are_targets_valid([t], self, actor)
	)
