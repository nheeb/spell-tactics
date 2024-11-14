class_name IdUtility extends CombatUtility

## All CombatObjects with IDs are referenced here
## {ID (int) -> CombatObject}
var combat_objects: Dictionary = {}

## Additional Infos about the CombatObjects
## {ID (int) -> Help Text (str)}
var object_names: Dictionary = {}

## One unique reference for each CombatObject
## {ID (int) -> CombatObjectReference}
var references: Dictionary = {}

func get_object(id: int) -> CombatObject:
	return combat_objects.get(id) as CombatObject

func get_object_name(id: int) -> String:
	return object_names.get(id, "") as String

func get_object_reference(id: int) -> CombatObjectReference:
	return references.get(id) as CombatObjectReference

func get_new_id() -> int:
	if references.is_empty():
		return 0
	return references.keys().max() + 1

func create_entries(id: int, object: CombatObject):
	object.id = id
	combat_objects[id] = object
	object_names[id] = str(object)
	var ref := get_object_reference(id)
	if ref:
		ref.connect_reference(combat)
		assert(ref.resolve(combat) == object)
	else:
		references[id] = CombatObjectReference.new(object)

func add_combat_object(object: CombatObject):
	assert(object != null)
	var id := object.id
	if id == -1:
		id = get_new_id()
	if id in combat_objects:
		if combat_objects[id] == object:
			push_warning("CombatObject %s was already added to ids." % str(object))
		else:
			var old_name := str(object)
			push_error("ID of %s is already in use by object: %s." % \
								[old_name, object_names[id]])
			id = get_new_id()
			object.id = id
			push_error("Changing ID of %s -> %s" % [old_name, str(object)])
	create_entries(id, object)

func remove_combat_object(object: CombatObject):
	var ref = get_object_reference(object.id)
	assert(ref, "Object has no reference.")
	if ref.removed:
		push_warning("Object was already removed from ids.")
	ref.removed = true
	object_names[object.id] = "[REMOVED] " + str(object)

func check_integrity() -> void:
	var integrity_broken := false
	for i in range(get_new_id()):
		var ref := get_object_reference(i)
		var _name := get_object_name(i)
		var object := get_object(i)
		if ref == null:
			integrity_broken = true
			push_warning("ID Integrity: No reference at %s" % i)
		elif object == null:
			if not ref.removed:
				integrity_broken = true
				push_warning("ID Integrity: No object at %s (%s)" % [i, _name])
	if integrity_broken:
		push_warning("ID Integrity: Everything will be rearranged.")
		rearrage_everything()

func rearrage_everything() -> void:
	var old_objects := combat_objects.values()
	combat_objects.clear()
	object_names.clear()
	references.clear()
	for obj in old_objects:
		create_entries(get_new_id(), obj)
