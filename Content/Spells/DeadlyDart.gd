extends SpellLogic

func execute() -> void:
	for enemy in target_enemies:
		combat.animation.effect(VFX.BILLBOARD_PROJECTILE, combat.player.visual_entity, \
			{"texture_name": spell.type.internal_name, "target": enemy.visual_entity})
		if enemy.get_status("Poison"):
			enemy.inflict_damage_with_visuals(99)
		else:
			enemy.apply_status(Preloaded.STATUS_POISON)
