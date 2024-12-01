extends SpellLogic

const TOTEM = preload("res://Content/Entities/FireTotem.tres")

func execute() -> void:
	var totem := TOTEM.create_entity(combat, target_tile)
	combat.animation.effect(VFX.HEX_RINGS, target_tile, {"color": Color.RED}).set_duration(1.5)
	combat.animation.show(totem.visual_entity).set_flag_with()

## Make sure there isnt another totem on the target tile
func is_target_valid(target: Variant, requirement: TargetRequirement) -> bool:
	assert(target is Tile)
	for e in target.entities:
		if "summoned" in e.get_tags():
			return false
	return true
