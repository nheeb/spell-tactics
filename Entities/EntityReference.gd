class_name EntityReference extends Resource

@export var id: EntityID

var ent: Entity

func _init(entity: Entity = null) -> void:
	ent = entity
	if entity == null:
		return
	id = entity.id
	if id == null:
		printerr("EntityReference was created on an entity with empty id")

func connect_reference(level: Level) -> void:
	for e in level.get_all_entities():
		if e.id.equals(id):
			if ent == e:
				printerr("EntityReference already connected to that object")
			else:
				if ent != null:
					printerr("EntityReference already connected to another object")
			ent = e
			break
	if ent == null:
		printerr("EntityReference did not get connected")

func resolve(combat: Combat = null) -> Entity:
	if ent != null:
		return ent
	else:
		if combat != null:
			connect_reference(combat.level)
			return ent
		else:
			printerr("EntityReference was not connected yet. Either connect it first or call resolve(combat)")
			return null

func is_valid(combat: Combat = null) -> bool:
	return resolve(combat) != null
