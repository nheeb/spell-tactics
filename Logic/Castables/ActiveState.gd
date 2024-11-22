class_name ActiveState extends Resource

@export var type: ActiveType
@export var id: ActiveID
@export var combat_persistant_properties := {}
@export var round_persistant_properties := {}

func deserialize(combat: Combat = null) -> Active:
	var active : Active = Active.new(type, combat)
	active.combat_persistant_properties = combat_persistant_properties
	active.round_persistant_properties = round_persistant_properties
	active.id = id
	return active
