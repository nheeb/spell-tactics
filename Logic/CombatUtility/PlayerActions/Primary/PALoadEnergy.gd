class_name PALoadEnergy extends PlayerAction

var orb : EnergyOrb
var energy_type: EnergyStack.EnergyType

func _init(_orb: EnergyOrb) -> void:
	orb = _orb
	energy_type = orb.type
	action_string = "Load Energy <%s>" % orb

func is_valid(combat: Combat) -> bool:
	if combat.input.current_castable:
		var card := combat.input.current_castable.get_card()
		if card:
			return card.get_empty_energy_socket(energy_type) != null
	return false

func execute(combat: Combat) -> void:
	combat.animation.callable(execute_animtaion.bind(combat)).add_ticket_to_parameter().set_max_duration(.35)

func execute_animtaion(combat: Combat, ticket: WaitTicket) -> void:
	var socket := combat.input.current_castable.get_card() \
			.get_empty_energy_socket(energy_type)
	orb.add_to_render_prio(100)
	orb.movement.bezier_jump(
		combat.ui.cards3d.energy_ui.global_position,
		combat.ui.cards3d.energy_bezier_point.global_position,
		socket, .45
	)
	orb.set_hoverable(false)
	socket.mark_to_be_loaded_soon()
	socket.pre_load_particles(energy_type, .45)
	await orb.movement.bezier_finished
	socket.load_energy(energy_type)
	orb.delete()
	ticket.resolve()

func on_fail(combat: Combat) -> void:
	pass

