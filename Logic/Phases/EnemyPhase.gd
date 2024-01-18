extends AbstractPhase

func process_phase() -> bool:
	combat.animation.callback(combat.ui, "set_status", ["Enemies attacking..."])
	
	# Sort enemies by agility
	combat.enemies.sort_custom(func(a: EnemyEntity, b: EnemyEntity): return a.type.agility > b.type.agility)
	
	for enemy in combat.enemies:
		enemy.do_movement()
		enemy.do_action()
	
	return false
