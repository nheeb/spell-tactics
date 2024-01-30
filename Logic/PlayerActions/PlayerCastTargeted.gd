class_name PlayerCastTargeted extends PlayerCast

var target

func _init(_spell: Spell, _payment: EnergyStack, _target) -> void:
	super(_spell, _payment)
	self.target = _target
	action_string = "Cast targeted %s on %s" % [_spell, _target]
	

func is_valid(combat: Combat) -> bool:
	var super_valid: bool = super(combat)
	# TODO valid target
	
	var range_valid = true
	if spell.type.target_range != -1:  # -1 means infinite range
		var dist: int
		if target is Tile:
			dist = Utility.tile_distance(target, combat.player.current_tile)
		elif target is Entity:
			dist = Utility.entity_distance(target, combat.player)
		else:
			printerr("Currently expecting Tile or Entity target for ranged spells.")
	
		range_valid = dist <= spell.type.target_range
		
	return super_valid and range_valid


func execute(combat: Combat) -> void:
	spell.logic.target = target
	spell.logic.cast(payment)
	if spell is Active:
		if spell.type.unlocked_once_per_round:
			spell.unlocked = false
