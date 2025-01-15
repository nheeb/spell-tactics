class_name CastableLogic extends CombatActionLogic

func get_castable() -> Castable:
	return combat_object as Castable

func cast() -> void:
	before_cast()
	await execute()
	after_cast()

################################################
## For overriding in SpellLogic & ActiveLogic ##
################################################

func before_cast() -> void:
	pass

func after_cast() -> void:
	combat.input.deselect_castable(get_castable())

#####################################
## For overriding in each Castable ##
#####################################

func is_selectable() -> bool:
	return true

func on_select_deselect(select: bool) -> void:
	pass

func get_costs() -> EnergyStack:
	return get_castable().type.costs
