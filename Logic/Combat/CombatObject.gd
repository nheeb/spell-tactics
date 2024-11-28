class_name CombatObject extends RefCounted
## Every combat-connected, referencable & serializable element is a CombatObject
## -> Tiles, Entities, Castables, Events, EntityStatus

## Reference to the object's combat
var combat: Combat

## Unique ID for that object
@export var id: int = -1
@export var data: Dictionary

@export var born := false
@export var dead := false

var node3d: Node3D
var position: Vector3:
	set(x):
		if node3d:
			node3d.position = x
	get:
		if node3d:
			return node3d.position
		return Vector3.ZERO
var global_position: Vector3:
	set(x):
		if node3d:
			node3d.global_position = x
	get:
		if node3d:
			return node3d.global_position
		return Vector3.ZERO

func get_reference() -> CombatObjectReference:
	var ref := combat.ids.references.get(id) as CombatObjectReference
	assert(ref, "CombatObject wasn't added to ids")
	return ref

func get_generic_type() -> CombatObjectType:
	return get("type") as CombatObjectType

func get_generic_logic() -> CombatLogic:
	return get("logic") as CombatLogic

func serialize() -> CombatObjectState:
	return CombatObjectState.new(self)

## ACTION
func on_birth() -> void:
	assert(not born)
	born = true
	if get_generic_logic():
		await get_generic_logic().on_birth()

## ACTION
func on_load() -> void:
	if get_generic_logic():
		await get_generic_logic().on_load()

## ACTION
func die() -> void:
	assert(combat != null and born and not dead)
	dead = true
	combat.ids.remove_combat_object(self)
	await combat.action_stack.process_callable(on_death)

## ACTION
func on_death() -> void:
	if get_generic_logic():
		await get_generic_logic().on_death()

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatObject was already connected to combat.")
	combat = _combat
	combat.ids.add_combat_object(self)

func sync_with_type(_type: CombatObjectType = null) -> void:
	_type = get_generic_type() if _type == null else _type
	assert(_type)
	set("type", _type)
	_type.set_type_properties(self)

func update_properties(props: Dictionary):
	for k in props.keys():
		if k == "data":
			data.merge(props[k], true)
		else:
			set(k, props[k])

func get_name() -> String:
	if get_generic_type():
		return get_generic_type().internal_name
	return "TypelessCO"

func _to_string() -> String:
	return "%s:%s" % [get_name(), str(id) if id >= 0 else "?"]
