class_name Castable extends CombatAction

var selected := false
var card: Card3D
var current_requirement: TargetRequirement
var current_possible_targets: Array

#########################
## Selecting & Casting ##
#########################

func is_selectable() -> bool:
	return get_logic().is_selectable()

func is_castable() -> bool:
	return are_requirements_fullfilled() \
		and is_energy_loaded_fully() \
		and get_logic().is_executable()

## ACTION
func cast() -> void:
	await get_logic().cast()

func select():
	selected = true
	details = CombatActionDetails.new(combat.player, self)
	animate_current_state()
	get_logic().on_select_deselect(true)

func deselect():
	selected = false
	details = null
	animate_current_state()
	get_logic().on_select_deselect(false)

################################
## Type, Logic & Card Getters ##
################################

func get_card() -> Card3D:
	return card

func get_logic() -> CastableLogic:
	return null

func get_type() -> CastableType:
	return null

func get_effect_text() -> String:
	return get_type().effect_text

############################
## Energy Payment Related ##
############################

func get_costs() -> EnergyStack:
	return get_logic().get_costs()

func player_has_enough_energy() -> bool:
	var energy := combat.energy.player_energy
	var costs := get_costs()
	return energy.get_possible_payment(costs) != null

func is_energy_loaded_fully() -> bool:
	# If it's quickcast, then there is no card
	if get_card() == null:
		return true
	return not get_card().has_empty_energy_sockets()

func on_energy_load():
	animate_current_state()

####################
## Visual Updates ##
####################

## ANIMATOR
func animate_current_state() -> AnimationObject:
	if selected:
		assert(details)
		current_requirement = get_next_requirement()
		if current_requirement:
			current_possible_targets = current_requirement.get_possible_targets(self)
	return combat.animation.callable(update_cast_visuals)

## ANIM
## This updates all ui / highlights / possible targets.
func update_cast_visuals() -> void:
	reset_cast_lines()
	build_cast_lines()
	update_tile_highlights()
	update_card()

## ANIM
func reset_cast_lines():
	combat.ui.cast_lines.clear()

## ANIM
func build_cast_lines():
	if selected:
		if get_costs().size() > 0:
			if not is_energy_loaded_fully():
				if player_has_enough_energy():
					combat.ui.cast_lines.add("Load the Energy", Color.ORANGE)
				else:
					combat.ui.cast_lines.add("Not enough Energy", Color.PALE_VIOLET_RED)
			else:
				combat.ui.cast_lines.add("Energy loaded", Color.MEDIUM_SEA_GREEN)
		var unfullfilled := get_unfullfilled_requirements()
		for req in get_target_requirements():
			if req in unfullfilled:
				if req == current_requirement:
					if current_possible_targets:
						combat.ui.cast_lines.add("Select the %s" % req.help_text, Color.ORANGE)
					else:
						combat.ui.cast_lines.add("No suitable %s" % req.help_text, Color.PALE_VIOLET_RED)
				else:
					combat.ui.cast_lines.add("%s not selected yet" % req.help_text, Color.LIGHT_GOLDENROD)
			else:
				pass
				# TBD Positive texts concerning target selection?
				combat.ui.cast_lines.add("%s selected" % req.help_text, Color.MEDIUM_SEA_GREEN)

## ANIM
func update_tile_highlights():
	# Clear all highlights
	var castable_highlights := Utility.array_unique(Utility.array_flat(
		get_target_requirements().map(
			func (req: TargetRequirement):
				return [req.possible_highlight, req.selected_highlight]
	)))
	for hl in castable_highlights:
		for tile in combat.level.get_all_tiles():
			tile.tile3d.set_highlight(hl, false)
	# Build new highlights
	if selected:
		for req in get_target_requirements():
			if req.type == TargetRequirement.Type.Tile:
				# Highlight all previously selected Tiles
				var selected_targets := details.get_target_array(req)
				if selected_targets:
					for target in selected_targets:
						if target is Tile:
							target.tile3d.set_highlight(req.selected_highlight, true)
				# Highlight all possible tiles
				elif req == current_requirement:
					for target in current_possible_targets:
						if target is Tile:
							target.tile3d.set_highlight(req.possible_highlight, true)

## ANIM
func update_card():
	if selected:
		if is_instance_valid(get_card()):
			get_card().set_glow(is_castable())
		else:
			push_error("Card for Castable visual update not found")
