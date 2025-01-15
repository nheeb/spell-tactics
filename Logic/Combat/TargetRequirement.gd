class_name TargetRequirement extends Resource

enum Type {
	Tile,
	Entity,
	SpellXX,
	EnergyStackXX
}

## Type of the target object / objects
@export var type: Type

enum Limitation {
	## Only Tiles without obstacle can be selected
	NoBlocker = 1,
	## Only Tiles with an enemy can be selected
	Foe = 2,
	## Only Tiles with an enemy can be selected
	Ally = 4,
	## Only Tiles with entity with target_tag can be selected
	EntityWithTag = 8,
	## Terrain will not be removed from the targets
	IncludeTerrain = 16,
	## Only Tiles that have more than terrain
	NoEmpty = 32,
}

## Common limitations for the selectable targets
## NOTE You maybe wonder why we have to write the flag-int-values a second time
## here in the export tag. Godot is CRINGE, that's why.
@export_flags(
	"No Blocker / Obstacle:1",
	"Foe:2",
	"Ally:4",
	"Entity with special Tag:8",
	"Include Terrain:16",
	"No empty Tile:32"
) var limitation: int

enum RangeSize {
	UNLIMITED = 0,
	ADJACENT_1 = 1,
	SHORT_2 = 2,
	MEDIUM_3 = 3,
	FAR_4 = 4,
	LONG_6 = 6,
	EXTREME_8 = 8,
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

## Details are needed for knowing the actor / origin tile.
func get_possible_targets(details: CombatActionDetails) -> Array:
	return convert_target(get_base_pool(details.combat_action.combat), details)

func get_base_pool(combat: Combat) -> Array:
	match type:
		Type.Tile:
			return combat.level.get_all_tiles()
		Type.Entity:
			return combat.level.get_all_entities()
	return []

####################################
## Filtering / Converting targets ##
####################################

## Takes a single / array of targets and converts them to whatever might suit the requirement.
## If the target is invalid it returns an empty array.
func convert_target(target: Variant, details: CombatActionDetails = null) -> Array:
	if target == null:
		return []
	if target is Array:
		if target.is_empty():
			return []
	var targets := Utility.array_from(target)
	targets = convert_targets_based_on_type(targets)
	targets = filter_null_and_duplicates(targets)
	targets = filter_based_on_limitation(targets, details)
	if details:
		targets = filter_based_on_range(targets, details)
		targets = filter_based_on_action_logic(targets, details)
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
			Type.Entity:
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

func filter_based_on_limitation(targets: Array, details: CombatActionDetails = null) -> Array:
	# Filter tiles with blocker
	if Utility.has_int_flag(limitation, Limitation.NoBlocker):
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return not t.is_blocked()
					return true
			)
	# Filter tiles with no foes
	if Utility.has_int_flag(limitation, Limitation.Foe) and details:
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return t.entities.any(
							func (e: Entity):
								return EntityType.are_teams_foes(
									e.team, details.actor.team
								)
						)
					return true
			)
		elif type == Type.Entity:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return EntityType.are_teams_foes(
									t.team, details.actor.team
								)
					return true
			)
	# Filter tiles with no allies
	if Utility.has_int_flag(limitation, Limitation.Ally) and details:
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return t.entities.any(
							func (e: Entity):
								return EntityType.are_teams_allies(
									e.team, details.actor.team
								)
						)
					return true
			)
		elif type == Type.Entity:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return EntityType.are_teams_allies(
									t.team, details.actor.team
								)
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
		elif type == Type.Entity:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return target_tag in t.type.tags
					return true
			)
	# If not include terrain, exclude it
	if not Utility.has_int_flag(limitation, Limitation.IncludeTerrain):
		if type == Type.Entity:
			targets = targets.filter(
				func (t):
					if t is Entity:
						return not t.type.is_terrain
					return true
			)
	# Filter empty tiles
	if Utility.has_int_flag(limitation, Limitation.NoEmpty):
		if type == Type.Tile:
			targets = targets.filter(
				func (t):
					if t is Tile:
						return t.entities.any(
							func (e: Entity):
								return not e.type.is_terrain
						)
					return true
			)
	return targets

func filter_based_on_range(targets: Array, details: CombatActionDetails) -> Array:
	if range_size == RangeSize.UNLIMITED:
		return targets
	return targets.filter(
		func (t):
			var tile := t as Tile
			if t is Entity:
				tile = t.current_tile
			if tile == null:
				return true
			return tile.distance_to(details.origin_tile) <= int(range_size)
	)

func filter_based_on_action_logic(targets: Array, details: CombatActionDetails) -> Array:
	return targets.filter(
		func (t: Variant):
			return details.combat_action.get_action_logic().is_target_valid(t, self)
	)
