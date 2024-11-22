class_name CombatActionDetails extends RefCounted

var origin: Entity
var target_requirements: Array[TargetRequirement]
## {TargetRequirement -> Array[Value]}
var target_details: Dictionary

func get_target_array(requirement_or_index) -> Array:
	var requirement: TargetRequirement
	if requirement_or_index is int:
		requirement = Utility.array_safe_get(target_requirements, requirement_or_index)
	elif requirement_or_index is TargetRequirement:
		requirement = requirement_or_index
	if requirement == null:
		push_error("Invalid requirement_or_index")
		return []
	var array := target_details.get(requirement, []) as Array
	return array

func get_target_value(requirement_or_index) -> Variant:
	return Utility.array_safe_get(get_target_array(requirement_or_index), 0)

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

#var target_tile: Tile:
	#get:
		#return target as Tile
#var targets: Array[Tile]
#var target_entities: Array[Entity]:
	#get:
		#if target is Tile:
			#return target.entities
		#return []
#var target_enemies: Array[EnemyEntity]:
	#get:
		#if target is Tile:
			#return target.get_enemies()
		#return []
#var target_enemy: EnemyEntity:
	#get:
		#return Utility.array_safe_get(target_enemies, 0)
