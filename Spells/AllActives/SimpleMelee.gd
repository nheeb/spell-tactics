class_name SimpleMelee extends ActiveLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Entity/Tile (if Spell is targetable)

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true
	

var modifiers: Array[CallableReference] = []  # (dmg, target_enemy) -> dmg

## Here should be the effect
func casting_effect() -> void:
	assert(target is Tile, "Melee expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "Melee expects min 1 enemy on tile")
	var enemy: EnemyEntity = enemies[0]
	var damage := 1
	for modifier in modifiers:
		var callable: Callable = modifier.resolve(combat)
		print(callable.get_method())
		print(callable)
		damage = callable.call(damage, enemy)
		print(callable.get_method())

	enemy.inflict_damage(damage)
	combat.animation.update_hp(enemy)
	combat.animation.say(combat.player.current_tile, "ATTACK!", {"color": Color.CORAL, "font": "bold"})

