extends SpellLogic

## Usable references:
## spell - Corresponding spell
##   (with round_persistant_properties & combat_persistant_properties)
## combat - The current combat for which the spell was created
## target - The target Tile (if Spell is targetable)

## The current costs with all the modifiers if there are any
#func _get_costs() -> EnergyStack:
	#return spell.type.costs

## This is for overriding if there are general cast-conditions
#func _is_unlocked() -> bool:
	#return true

## This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true

var acc_loss := 3
var damage := 3

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		enemy.apply_status_effect(BlindEffect.new(acc_loss))
		combat.animation.say(enemy.visual_entity,\
		 "-%s Acc" % acc_loss).set_flag_extend().set_duration(0.5).set_delay(1.0)
		var corpse_drain := combat.log.get_last_incident("drained_tag_corpse")
		if corpse_drain:
			if corpse_drain.round_number == combat.current_round:
				enemy.inflict_damage_with_visuals(damage)
				combat.animation.say(enemy.visual_entity, "%s Damage" % acc_loss, \
					 {"color": Color.RED}).set_flag_extend().set_duration(1.0)

