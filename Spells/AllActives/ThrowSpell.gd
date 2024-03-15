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
	assert(target is Tile)
	target = target as Tile
	
	var card_choice := CardChoiceActivity.new(combat.ui.cards3d, 1)
	combat.animation.combat_choice(card_choice)
	await card_choice.resolved
	var discarded_spells : Array = card_choice.get_result()
	for discarded_spell in discarded_spells:
		combat.cards.discard(discarded_spell)
	
		for enemy in target.get_enemies():
			enemy = enemy as EnemyEntity
			
			combat.animation.effect(VFX.BILLBOARD_PROJECTILE, combat.player.visual_entity,\
									 {"texture_name": "flying_spell", "target": enemy.visual_entity})
			
			enemy.inflict_damage_with_visuals(1, true)

