class_name EntityLogic extends CombatLogic

var entity: Entity:
	get:
		return combat_object as Entity
	set(x):
		push_error("Do not set this.")

func get_reference() -> PropertyReference:
	return PropertyReference.new(entity.get_reference(), "logic")
