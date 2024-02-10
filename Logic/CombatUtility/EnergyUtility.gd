class_name EnergyUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

@onready var player_energy: EnergyStack = EnergyStack.new([])

var drains_done_this_turn := 0

func pay(payment: EnergyStack) -> AnimationObject:
	# style: is this utility method needed or should it be moved here?
	player_energy.apply_payment(payment)
	player_energy.sort()
	return combat.animation.callback(combat.ui, "set_current_energy", [player_energy.duplicate(true)])
	
func is_payable(payment: EnergyStack) -> bool:
	var possible: EnergyStack = player_energy.get_possible_payment(payment)
	return possible != null

func gain(energy: EnergyStack) -> AnimationObject:
	player_energy.stack.append_array(energy.stack)
	player_energy.sort()
	return combat.animation.callback(combat.ui, "set_current_energy", [player_energy.duplicate(true)])
