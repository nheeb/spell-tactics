class_name EnergyUtility extends Node

@onready var combat : Combat = get_parent().get_parent()

func pay(payment: Array[Game.Energy]) -> void:
	Game.combat.player_energy = Utility.pay_energy(Game.combat.player_energy, payment)
	Game.combat.animation_queue.append(AnimationObject.new(Game.hand_ui, "set_current_energy", [Game.combat.player_energy.duplicate()]))
