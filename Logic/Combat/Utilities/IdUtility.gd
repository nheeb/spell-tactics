class_name IdUtility extends CombatUtility

## All CombatObjects with IDs are referenced here
## {ID (int) -> CombatObject}
var combat_objects: Dictionary = {}

## Additional Infos about the CombatObjects
## {ID (int) -> Help Text (str)}
var help_texts: Dictionary = {}

var highest_id := 0

func update_highest_id(id: int):
	highest_id = max(highest_id, id)

func get_new_id() -> int:
	highest_id += 1
	return highest_id

func add_combat_object(object: CombatObject, id: int = -1):
	assert(object != null)
	assert(object.id <= 0 or object.id == id, "Object already has a (different) ID.")
	if id == -1:
		id = get_new_id()
	update_highest_id(id)
	assert(id not in combat_objects, "ID is already in use.")
	combat_objects[id] = object
	help_texts[id] = str(object)
	object.id = id
