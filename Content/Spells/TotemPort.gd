extends SpellLogic

func execute() -> void:
	combat.movement.blink_entity(combat.player, target_tile)

func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	assert(target is Tile)
	for tile in target.get_surrounding_tiles():
		for e in tile.entities:
			if "summoned" in e.get_tags():
					return true
	return false
