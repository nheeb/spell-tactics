class_name EnergyUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

var player_energy: Array[Game.Energy]

func pay(payment: Array[Game.Energy]) -> void:
	# style: is this utility method needed or should it be moved here?
	player_energy = Utility.pay_energy(player_energy, payment)
	combat.animation.callback(combat.ui, "set_current_energy", [player_energy.duplicate()])
