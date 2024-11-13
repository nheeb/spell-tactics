class_name IdUtility extends CombatUtility

## All CombatObjects with IDs are referenced here
## {ID (int) -> CombatObject}
var combat_objects: Dictionary = {}

## Additional Infos about the CombatObjects
## {ID (int) -> Help Text (str)}
var help_texts: Dictionary = {}

var highest_id := 0

func update_highest_id(id: int = -1):
	if id == -1:
		highest_id = combat_objects.keys().max()
	else:
		highest_id = max(highest_id, id)

func get_new_id() -> int:
	highest_id += 1
	return highest_id

func add_combat_object(object: CombatObject):
	assert(object != null)
	var id := object.id
	if id == -1:
		id = get_new_id()
	update_highest_id(id)
	if id in combat_objects:
		if combat_objects[id] == object:
			push_warning("CombatObject was already added to ids.")
		else:
			var old_name := str(object)
			push_error("ID of %s is already in use by object: %s." % \
								[old_name, help_texts[id]])
			id = get_new_id()
			object.id = id
			push_error("Changing ID of %s -> %s" % [old_name, str(object)])
	combat_objects[id] = object
	object.id = id
	help_texts[id] = str(object)
	
