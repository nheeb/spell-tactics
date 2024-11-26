class_name Castable extends CombatAction

var selected := false
var current_requirement: TargetRequirement
var current_possible_targets: Array

#########################
## Selecting & Casting ##
#########################

func is_selectable() -> bool:
	return false

func is_castable() -> bool:
	return are_requirements_fullfilled()

## ACTION
func cast() -> void:
	await get_logic().cast()

func select():
	selected = true
	details = CombatActionDetails.new(combat.player, self)
	get_logic().on_select_deselect(true)
	update_current_state()

func deselect():
	selected = false
	details = null
	get_logic().on_select_deselect(false)
	update_current_state()

################################
## Type, Logic & Card Getters ##
################################

func get_card() -> Card3D:
	return null

func get_logic() -> CastableLogic:
	return null

func get_type() -> CastableType:
	return null

func get_effect_text() -> String:
	return get_type().effect_text

####################
## Visual Updates ##
####################

## ANIMATOR
func update_current_state() -> AnimationObject:
	if selected:
		assert(details)
		current_requirement = get_next_requirement()
		if current_requirement:
			current_possible_targets = current_requirement.get_possible_targets(self, details.actor)
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
		var unfullfilled := get_unfullfilled_requirements()
		for req in get_target_requirements():
			if req in unfullfilled:
				if req == current_requirement:
					if current_possible_targets:
						combat.ui.cast_lines.add("Select the %s!" % req.help_text, Color.ORANGE)
					else:
						combat.ui.cast_lines.add("No suitable %s" % req.help_text, Color.RED)
				else:
					combat.ui.cast_lines.add("%s not selected yet" % req.help_text, Color.LIGHT_GOLDENROD)
			else:
				combat.ui.cast_lines.add("%s was selected" % req.help_text, Color.WEB_GREEN)

## ANIM
func update_tile_highlights():
	# TODO Clear all highlights
	if selected:
		for req in get_target_requirements():
			if req.type == TargetRequirement.Type.Tile:
				# Highlight all previously selected Tiles
				var selected_targets := details.get_target_array(req)
				if selected_targets:
					for target in selected_targets:
						if target is Tile:
							target.set_highlight(req.selected_highlight, true)
				# Highlight all possible tiles
				elif req == current_requirement:
					for target in current_possible_targets:
						if target is Tile:
							target.set_highlight(req.possible_highlight, true)

## ANIM
func update_card():
	if is_instance_valid(get_card()):
		get_card().set_glow(is_castable())
	else:
		push_error("Card for Castable visual update not found")
