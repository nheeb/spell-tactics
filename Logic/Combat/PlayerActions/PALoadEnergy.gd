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
	combat.input.block_input(InputUtility.InputBlockType.OrbTransition, true)
	var socket := combat.input.current_castable.get_card() \
		.get_empty_energy_socket(energy_type)
	assert(socket)
	socket.load_energy(energy_type)
	if orb.energy_count > 1:
		orb.energy_count -= 1
		orb = orb.create_single_orb()
	orb.set_hoverable(false)
	var anim := combat.animation.callable(execute_animation.bind(combat, socket, orb)) \
		.add_wait_ticket_to_args().set_max_duration(.35)
	combat.action_stack.active_ticket.finish()
	await anim.animation_done
	await VisualTime.new_timer(.3).timeout
	combat.input.block_input(InputUtility.InputBlockType.OrbTransition, false)

## ANIM
func execute_animation(combat: Combat, socket: HandCardEnergySocket, \
		_orb: EnergyOrb, ticket: WaitTicket) -> void:
	_orb.add_to_render_prio(50)
	
	#print(combat.ui.cards3d.energy_ui.global_position.distance_to(_orb.global_position))
	# FIXME This is very dirty but for some reason the new split orbs spawn at weird position
	if combat.ui.cards3d.energy_ui.global_position \
		.distance_squared_to(_orb.global_position) > 1.0:
		_orb.global_position = combat.ui.cards3d.energy_ui.global_position
	
	_orb.movement.bezier_jump(
		combat.ui.cards3d.energy_ui.global_position,
		combat.ui.cards3d.energy_bezier_point.global_position,
		socket, .6
	)

	socket.pre_load_particles(energy_type, .6)
	await _orb.movement.bezier_finished
	socket.load_animation(energy_type)
	_orb.delete()
	await VisualTime.visual_process
	ticket.resolve()
