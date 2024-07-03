extends ActiveLogic

## Usable references:
## active - Corresponding active
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the active was created
## target - The target Tile (if active is targetable)
## targets - Array of target tiles (if active has multiple targets)


## Here should be the effect
func casting_effect() -> void:
	#combat.energy.add_a_drain()
	
	for entity in target.entities:
		entity = entity as Entity
		var energy_stack : EnergyStack = null
		#if not entity.is_drainable() and not entity.type.is_terrain:
			#continue
		# entity.drain() removes the energy from that entity as a side-effect
		if entity.is_drainable():
			energy_stack = entity.drain()
			combat.energy.gain(energy_stack)
		combat.animation.callback(entity.visual_entity, "visual_drain").set_max_duration(.5)
		#if energy_stack:
			#combat.animation.callback(entity.visual_entity, "spawn_energy_orbs",\
					#[energy_stack, combat.player.visual_entity.orbital_movement_body])\
					#.set_max_duration(.5).set_flag_with()
			#combat.animation.callback(combat.ui.cards3d.energy_ui, "spawn_energy_orbs",\
					#[energy_stack]).set_max_duration(.5).set_flag_with()
		for tag in entity.get_tags():
			combat.log.register_incident("drained_tag_%s" % tag)

## active can be selected
#func _is_selectable() -> bool:
	#return true

## active can be casted
#func _is_castable() -> bool:
	#return true

## Can a target tile be selected
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	return _target.is_drainable()

## Visuals or something else on active select / deselect
#func _on_select_deselect(select: bool) -> void:
	#pass

## Does the active take additional targets
#func _are_targets_full(_targets: Array[Tile]) -> bool:
	#return true

## Are the selected targets valid
#func _are_targets_castable(_targets: Array[Tile]) -> bool:
	#return true

## Set special preview visuals when a target is hovered / selected
#func _set_preview_visuals(_target: Tile, active: bool) -> void:
	#pass

