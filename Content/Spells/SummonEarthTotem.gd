extends SpellLogic

const TOTEM = preload("res://Content/Entities/EarthTotem.tres")


func casting_effect() -> void:
	target = target as Tile
	var totem := combat.level.entities.create(target.location, TOTEM, false)
	combat.animation.effect(VFX.HEX_RINGS, target, {"color": Color.SADDLE_BROWN}).set_duration(1.5)
	combat.animation.show(totem.visual_entity).set_flag_with()


##Make sure there isnt another totem on the target tile
func _is_target_suitable(_target: Tile, target_index: int = 0) -> bool:
	target = _target as Tile
	for e in target.entities:
		if "summoned" in e.get_tags():
			return false
	return true
