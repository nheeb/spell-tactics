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

## Here should be the effect
func casting_effect() -> void:
	target = target as Tile
	var decay_energy := combat.energy.player_energy.count(EnergyStack.EnergyType.Decay)
	var additional_payment := 0
	if decay_energy >= 1:
		var choice = PlayerChoiceActivity.new("Do you want to pay extra Decay Energy?", \
		range(decay_energy+1), range(decay_energy+1).map(func (i): return "Pay %s extra" % i))
		combat.animation.player_choice(choice)
		await choice.resolved
		additional_payment = choice.get_result()
	for i in range(additional_payment):
		combat.energy.pay(EnergyStack.single_energy_from_type(EnergyStack.EnergyType.Decay))
	var total_damage = additional_payment + 1
	for enemy in target.get_enemies():
		enemy = enemy as EnemyEntity
		combat.animation.say(enemy.visual_entity, "%s Damage" % total_damage,\
		 {"color": Color.RED, \
		"font_size": 64 + int(Utility.clamp_map(total_damage, 1, 6, 0, 64))}).set_duration(.5)
		enemy.inflict_damage_with_visuals(total_damage)
