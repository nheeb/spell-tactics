class_name UniversalReference extends Resource

## If this is false, resolve() will call connect_reference() every time.
@export var cache_result := true

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	pass # TODO Conncet to object with combat

func resolve(combat: Combat = null) -> Variant:
	assert(cache_result or combat != null)
	if _resolve() != null and cache_result:
		return _resolve()
	else:
		if combat != null:
			connect_reference(combat)
			return _resolve()
		else:
			push_error("%s was not connected yet. Either connect it first or call resolve(combat)" % get_reference_type())
			return null

## Is being called by resolve and should never be called from outside.
func _resolve() -> Variant:
	return null # TODO Return the object

func is_valid(combat: Combat = null) -> bool:
	return resolve(combat) != null

func _to_string() -> String:
	return "%s (%s)" % [get_reference_type(), "Connected: %s" % _resolve() if is_valid() else "Not connected"]

func get_reference_type() -> String:
	return "Abstract UniversalReference"

func equals(other: UniversalReference, combat: Combat = null) -> bool:
	return resolve(combat) == other.resolve(combat)

##################################################
## Static Methods for (de)referencing variables ##
##################################################

static func from(object: Object) -> UniversalReference:
	if object == null:
		return null
	if object is UniversalReference:
		return object
	if object.has_method("get_reference"):
		return object.get_reference()
	push_error("Object has no reference.")
	return null

static func reference_or_value(x: Variant) -> Variant:
	if x is Object:
		if x.has_method("get_reference"):
			assert(x is not UniversalReference, "Reference with get_ref??")
			var ref = x.get_reference()
			assert(ref is UniversalReference, "get_ref returns no reference")
			return ref
	return x

static func dereference_array(array: Array, combat: Combat) -> Array:
	var deref := []
	for x in array:
		deref.append(dereference(x, combat))
	return deref

static func dereference_dict(dict: Dictionary, combat: Combat) -> Dictionary:
	var deref := {}
	for k in dict.keys():
		var v = dict[k]
		var key = dereference(k, combat)
		var value = dereference(v, combat)
		deref[key] = value
	return deref

static func dereference(x: Variant, combat: Combat) -> Variant:
	if x is UniversalReference:
		return x.resolve(combat)
	elif x is Array:
		return dereference_array(x, combat)
	elif x is Dictionary:
		return dereference_dict(x, combat)
	else:
		return x

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

func get_callable(combat: Combat) -> Callable:
	assert(resolve(combat) is Callable)
	return resolve(combat) as Callable

func get_status(combat: Combat) -> EntityStatus:
	assert(resolve(combat) is EntityStatus)
	return resolve(combat) as EntityStatus
