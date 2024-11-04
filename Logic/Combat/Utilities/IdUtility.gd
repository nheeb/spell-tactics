extends CombatUtility

## All CombatObjects with IDs are referenced here
## {CombatID -> CombatObject}
var combat_objects: Dictionary = {}

func add_combat_object(object: CombatObject, id: CombatID = null)
