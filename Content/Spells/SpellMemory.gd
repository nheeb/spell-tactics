extends SpellLogic

func execute() -> void:
	combat.cards.draw()
	combat.cards.draw()
	combat.cards.draw()
	combat.player.inflict_heal_with_visuals(1)
