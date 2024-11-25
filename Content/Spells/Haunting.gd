extends SpellLogic

var acc_loss := 3
var damage := 3

func execute() -> void:
	target = target as Tile
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		#enemy.apply_status_effect(BlindEffect.new(acc_loss))
		enemy.apply_status(Preloaded.STATUS_BLIND)
		combat.animation.say(enemy.visual_entity,\
		 "-%s Acc" % acc_loss).set_flag_extend().set_duration(0.5).set_delay(1.0)
		
		#var corpse_drain := combat.log.get_last_incident("drained_tag_corpse")
		#if corpse_drain:
			#if corpse_drain.round_number == combat.current_round:
				#enemy.inflict_damage_with_visuals(damage)
				#combat.animation.say(enemy.visual_entity, "%s Damage" % acc_loss, \
					 #{"color": Color.RED}).set_flag_extend().set_duration(1.0)
