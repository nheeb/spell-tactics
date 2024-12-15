extends SpellLogic

func execute() -> void:
	var base_damage := 3
	var bonus_damage := 2
	
	var line := combat.player.current_tile.get_line(target_tile)
	
	
	var anims = []
	for tile in line:
		anims.append(combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_duration(0.1))
		anims.append(combat.animation.show(tile).set_flag_with())
		
		
	for enemy in target_enemies:
		if enemy.get_status("Wet"):
			enemy.inflict_damage_with_visuals(base_damage + bonus_damage)
		else:
			enemy.inflict_damage_with_visuals(base_damage)
