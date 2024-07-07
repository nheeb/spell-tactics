class_name PAUnloadSocket extends PlayerAction

var socket: HandCardEnergySocket

func _init(_socket: HandCardEnergySocket) -> void:
	socket = _socket
	action_string = "Unload Socket <%s>" % socket

func is_valid(combat: Combat) -> bool:
	return socket.is_loaded

func execute(combat: Combat) -> void:
	var energy := socket.unload_energy()
	combat.ui.cards3d.energy_ui.spawn_energy_orbs(EnergyStack.new([energy]))

func on_fail(combat: Combat) -> void:
	pass

