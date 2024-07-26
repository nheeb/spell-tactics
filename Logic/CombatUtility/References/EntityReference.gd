class_name EntityReference extends UniversalReference

@export var id: EntityID

var ent: Entity

func _init(entity: Entity = null) -> void:
	if entity == null:
		return
	ent = entity
	id = entity.id
	assert(id)
	if id == null:
		push_error("EntityReference was created on an entity with empty id")

## Is called by resolve(combat)
func connect_reference(combat: Combat) -> void:
	for e in combat.level.entities().get_all_entities():
		if e.id.equals(id):
			if ent == e:
				push_error("EntityReference already connected to that object")
			else:
				if ent != null:
					push_error("EntityReference already connected to another object")
			ent = e
	if ent == null:
		push_error("EntityReference did not get connected")

## Is being called by resolve and should never be called from outside.
func _resolve() -> Object:
	return ent

func get_reference_type() -> String:
	return "SpellReference"
