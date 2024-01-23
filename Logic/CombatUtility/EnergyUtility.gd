class_name EnergyUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

@onready var player_energy: EnergyStack = EnergyStack.new([])

func pay(payment: EnergyStack) -> void:
	# style: is this utility method needed or should it be moved here?
	player_energy.apply_payment(payment)
	combat.animation.callback(combat.ui, "set_current_energy", [player_energy.duplicate(true)])


func gain(energy: EnergyStack) -> void:
	player_energy.append_array(energy)
	combat.animation.callback(combat.ui, "set_current_energy", [player_energy.duplicate(true)])
