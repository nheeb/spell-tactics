extends SpellLogic

func casting_effect() -> void:
	for i in range(2):
		combat.cards.draw()

