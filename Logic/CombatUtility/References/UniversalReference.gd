class_name UniversalReference extends Resource

## If this is false, resolve() will call connect_reference() every time.
@export var cache_result := true

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	pass # TODO Conncet to object with combat

func resolve(combat: Combat = null) -> Object:
	assert(cache_result or combat != null)
	if _resolve() != null and cache_result:
		return _resolve()
	else:
		if combat != null:
			connect_reference(combat)
			return _resolve()
		else:
			printerr("%s was not connected yet. Either connect it first or call resolve(combat)" % get_reference_type())
			return null

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return null # TODO Return the object

func is_valid(combat: Combat = null) -> bool:
	return resolve(combat) != null

func _to_string() -> String:
	return "%s (%s)" % [get_reference_type(), "Connected: %s" % _resolve() if is_valid() else "Not connected"]

func get_reference_type() -> String:
	return "Abstract UniversalReference"

##########################################
## Getters for the different References ##
##########################################

func get_castable(combat: Combat) -> Castable:
	assert(resolve(combat) is Castable)
	return resolve(combat) as Castable

func get_spell(combat: Combat) -> Spell:
	assert(resolve(combat) is Spell)
	return resolve(combat) as Spell

func get_active(combat: Combat) -> Active:
	assert(resolve(combat) is Active)
	return resolve(combat) as Active

func get_event(combat: Combat) -> CombatEvent:
	assert(resolve(combat) is CombatEvent)
	return resolve(combat) as CombatEvent

func get_enemy_event(combat: Combat) -> EnemyEvent:
	assert(resolve(combat) is EnemyEvent)
	return resolve(combat) as EnemyEvent

func get_entity(combat: Combat) -> Entity:
	assert(resolve(combat) is Entity)
	return resolve(combat) as Entity

func get_tile(combat: Combat) -> Tile:
	assert(resolve(combat) is Tile)
	return resolve(combat) as Tile

func get_node(combat: Combat) -> Node:
	assert(resolve(combat) is Node)
	return resolve(combat) as Node
