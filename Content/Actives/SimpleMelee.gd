class_name SimpleMelee extends ActiveLogic

const BASE_DMG = 1

## Here should be the effect
func execute() -> void:
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Damage) \
		.add_tag(ActionFlavor.Tag.Melee) \
		.set_owner(combat.player) \
		.add_target(target_enemy) \
		.finalize(combat)
	var damage: int = await combat.action_stack.get_discussion_result(BASE_DMG, flavor)

	target_enemy.inflict_damage_with_visuals(damage)
	combat.animation.say(combat.player.current_tile, "ATTACK!", \
		{"color": Color.CORAL, "font": "bold"})
