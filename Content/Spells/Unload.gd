extends SpellLogic

func casting_effect() -> void:
	assert(target is Tile, "Unleash expecting Tile as target")
	target = target as Tile
	var enemies = target.get_enemies()
	assert(len(enemies) >= 1, "Unleash expects min 1 enemy on tile")
	
	var hand_size = len(combat.hand) - 1
	for card in combat.hand:
		combat.cards.discard(card)
	
	for enemy in enemies:
		enemy.inflict_damage_with_visuals(hand_size)
	
	for i in range(3):
		combat.cards.draw()
