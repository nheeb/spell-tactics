class_name SimpleMelee extends ActiveLogic

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "Melee expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "Melee expects min 1 enemy on tile")
	var enemy: EnemyEntity = enemies[0]
	var damage := 1
	
	var flavor := ActionFlavor.new() \
		.add_action(ActionFlavor.Action.Damage) \
		.add_action(ActionFlavor.Action.Melee) \
		.set_owner(combat.player) \
		.add_target(enemy)
	var actual_damage_result := combat.action_stack.start_discussion(damage, flavor)
	await combat.action_stack.wait()
	damage = actual_damage_result.value

	enemy.inflict_damage(damage)
	combat.animation.update_hp(enemy)
	combat.animation.say(combat.player.current_tile, "ATTACK!", {"color": Color.CORAL, "font": "bold"})
