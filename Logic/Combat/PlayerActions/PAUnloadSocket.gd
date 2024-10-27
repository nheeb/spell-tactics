class_name PAUnloadSocket extends PlayerAction

var socket: HandCardEnergySocket

func _init(_socket: HandCardEnergySocket) -> void:
	socket = _socket
	action_string = "Unload Socket <%s>" % socket

func is_valid(combat: Combat) -> bool:
	return socket.is_loaded

func execute(combat: Combat) -> void:
	combat.animation.callable(execute_animation.bind(combat)).add_ticket_to_parameter()

func execute_animation(combat: Combat, ticket: WaitTicket) -> void:
	var energy := socket.unload_energy()
	combat.ui.cards3d.energy_ui.spawn_energy_orbs(EnergyStack.new([energy]))
	ticket.resolve_on(VisualTime.new_timer(.15).timeout)

func on_fail(combat: Combat) -> void:
	pass
