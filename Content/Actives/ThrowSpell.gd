extends ActiveLogic

## Here should be the effect
func execute() -> void:
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
