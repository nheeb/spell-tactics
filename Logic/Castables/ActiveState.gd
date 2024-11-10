class_name ActiveState extends CombatObjectState

@export var type: ActiveType
@export var data := {}

func deserialize(combat: Combat = null) -> Active:
	var active : Active = Active.new(type, combat)
	active.data = data
	active.id = id
	return active
