extends SpellLogic

func execute() -> void:
	var hand_size = len(combat.hand) - 1
	for card in combat.hand:
		combat.cards.discard(card)
	
	for enemy in target_enemies:
		enemy.inflict_damage_with_visuals(hand_size)
	
	for i in range(3):
		combat.cards.draw()
