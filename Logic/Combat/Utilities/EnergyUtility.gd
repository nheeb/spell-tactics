class_name EnergyUtility extends CombatUtility

@onready var player_energy: EnergyStack = EnergyStack.new([])

var drains_done_this_turn := 0

func pay(payment: EnergyStack, explode_in_ui := false) -> AnimationObject:
	player_energy.apply_payment(payment)
	return explode_energy_orbs(payment, explode_in_ui)

func explode_energy_orbs(payment: EnergyStack, explode_in_ui: bool) -> AnimationObject:
	var anims := []
	var bodies := [combat.player.visual_entity.orbital_movement_body]
	if explode_in_ui:
		bodies.append(combat.ui.cards3d.energy_ui.omb)
	for body in bodies:
		var orbs : Array = body.get_children().filter(func(c): return c is EnergyOrb)
		for payment_type in payment.stack:
			var target_orb = null
			for orb in orbs:
				if orb.type == payment_type:
					target_orb = orb
					break
			if is_instance_valid(target_orb):
				anims.append(combat.animation.call_method(target_orb, "death"))
				orbs.erase(target_orb)
	return combat.animation.reappend_as_subqueue(anims).set_flag_with()

func is_payable(payment: EnergyStack) -> bool:
	var possible: EnergyStack = player_energy.get_possible_payment(payment)
	return possible != null

func gain(energy: EnergyStack, entity: Entity = null) -> AnimationObject:
	player_energy.stack.append_array(energy.stack)
	return spawn_orbs(energy, entity)

func spawn_orbs(energy: EnergyStack, entity: Entity) -> AnimationObject:
	var anims: Array[AnimationObject] = []
	if entity and entity.visual_entity:
		anims.append(
			combat.animation.call_method(entity.visual_entity, "spawn_energy_orbs",\
				[energy, combat.player.visual_entity.orbital_movement_body])\
				.set_max_duration(.5).set_flag_with()
		)
	anims.append(
		combat.animation.call_method(combat.ui.cards3d.energy_ui, "spawn_energy_orbs",\
			[energy]).set_max_duration(.5).set_flag_with()
	)
	return combat.animation.reappend_as_subqueue(anims)


#func show_energy_in_ui() -> AnimationCallable:
	#player_energy.sort()
	#return combat.animation.call_method(combat.ui, "set_current_energy", \
										 #[player_energy.duplicate(true)])

#func reset_drains() -> AnimationCallable:
	#drains_done_this_turn = 0
	#return show_drains_in_ui()
#
#func add_a_drain(drains := 1) -> AnimationCallable:
	#drains_done_this_turn += drains
	#return show_drains_in_ui()
#
#func show_drains_in_ui() -> AnimationCallable:
	#var drains_left : int = combat.player.traits.max_drains - drains_done_this_turn
	#return combat.animation.call_method(combat.ui, "set_drains_left", [drains_left])
