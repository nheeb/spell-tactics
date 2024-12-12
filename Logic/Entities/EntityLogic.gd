class_name EntityLogic extends CombatLogic

var entity: Entity:
	get:
		return combat_object as Entity
	set(x):
		push_error("Do not set this.")

#########################
## Methods to override ##
#########################

## ACTION
func on_drain() -> void:
	pass

## ACTION
func on_interact() -> void:
	pass
