class_name SimpleMelee extends ActiveLogic

const BASE_DMG = 1

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "Melee expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "Melee expects min 1 enemy on tile")
	var enemy: EnemyEntity = enemies[0]
	
	var flavor := ActionFlavor.new() \
		.add_tag(ActionFlavor.Tag.Damage) \
		.add_tag(ActionFlavor.Tag.Melee) \
		.set_owner(combat.player) \
		.add_target(enemy) \
		.finalize(combat)
	var damage: int = await combat.action_stack.get_discussion_result(BASE_DMG, flavor)

	enemy.inflict_damage_with_visuals(damage)
	combat.animation.say(combat.player.current_tile, "ATTACK!", \
		{"color": Color.CORAL, "font": "bold"})
