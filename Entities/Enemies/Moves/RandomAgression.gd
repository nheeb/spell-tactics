extends EnemyMove

var target: Entity

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	target = null
	var surrounding_tiles = enemy.current_tile.get_surrounding_tiles()
	surrounding_tiles.shuffle()
	for tile in surrounding_tiles:
		for ent in tile.entities:
			if (not ent is HPEntity) and (not ent.type.is_terrain):
				target = ent
	if target == null:
		return 0.0
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Fighter:
			return 2.0
		EnemyEntityType.Behaviour.Archer:
			return .5
	return 0.0

## Executes the move
func execute() -> void:
	assert(target != null)
	combat.animation.say(enemy.visual_entity, "\"I hate this %s!\"" % target.type.pretty_name, {"duration": 2.0})
	combat.animation.effect(VFX.HEX_RINGS, target.current_tile, {"color": Color.RED}).set_flag_with()
	combat.animation.say(enemy.visual_entity, "Punch!")
	combat.animation.property(target.visual_entity, "visible", false).set_flag_with().set_delay(.3)
	combat.level.move_entity_to_graveyard(target)
