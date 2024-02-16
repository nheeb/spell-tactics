class_name PlayerCastTargeted extends PlayerCast

var target

func _init(_spell: Spell, _payment: EnergyStack, _target) -> void:
	super(_spell, _payment)
	self.target = _target
	action_string = "Cast targeted %s on %s" % [_spell, _target]
	

func is_valid(combat: Combat) -> bool:
	var super_valid: bool = super(combat)
	
	# Target Range Validation
	var range_valid = true
	if not target is Array[Tile]:
		if spell.type.target_range != -1 or spell.type.target_min_range != -1:  # -1 means infinite range
			var dist: int
			if target is Tile:
				dist = Utility.tile_distance(target, combat.player.current_tile)
			elif target is Entity:
				dist = Utility.entity_distance(target, combat.player)
			else:
				printerr("Currently expecting Tile, Tile Array or Entity target for ranged spells.")
		
			if spell.type.target_range != -1:
				range_valid = dist <= spell.type.target_range
			if spell.type.target_min_range != -1:
				range_valid = range_valid and (dist >= spell.type.target_min_range)
		
	if not (range_valid and super_valid):
		return false  # early stopping :)
	
	# Target Type validation
	var target_valid = true
	if spell.type.target != SpellType.Target.None:
		match spell.type.target:
			SpellType.Target.Tile:
				pass  # any tile is valid
			SpellType.Target.Enemy:
				if target is Tile:
					target_valid = target.has_enemy()
				elif target is Entity:
					target_valid = target is EnemyEntity
			SpellType.Target.TileWithoutObstacles:
				if target is Tile:
					# valid if the target tile does NOT have any entities with Nav obstacle layer
					target_valid = not bool(target.get_obstacle_layers() & EntityType.NAV_OBSTACLE_LAYER)
				else:
					target_valid = false
			SpellType.Target.Tag:
				assert(target is Tile)
				target_valid = spell.type.target_tag in target.get_tags()
			SpellType.Target.Condition:
				printerr("Target custom condition not implemented yet.")
				target_valid = false
			SpellType.Target.Cone:
				target_valid = len(target) > 0

	return super_valid and range_valid and target_valid


func execute(combat: Combat) -> void:
	spell.logic.target = target
	super.execute(combat)
	#if spell is Active:
		#if spell.type.unlocked_once_per_round:
			#spell.unlocked = false
