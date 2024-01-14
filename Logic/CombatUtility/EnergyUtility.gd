class_name EnergyUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func pay(payment: Array[Game.Energy]) -> void:
	combat.player_energy = Utility.pay_energy(combat.player_energy, payment)
	combat.animation_queue.append(AnimationObject.new(Game.combat_ui, "set_current_energy", [combat.player_energy.duplicate()]))
