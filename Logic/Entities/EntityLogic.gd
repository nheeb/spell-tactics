class_name EntityLogic extends CombatLogic

var entity: Entity:
	get:
		return combat_object as Entity
	set(x):
		push_error("Do not set this.")

func on_graveyard():
	pass

## Executed when the logic is created or loaded (Put visuals in here)
func on_create():
	pass

func get_reference() -> PropertyReference:
	return PropertyReference.new(entity.get_reference(), "logic")
