extends EnemyMove

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	match enemy.type.behaviour:
		EnemyEntityType.Behaviour.Archer:
			return 2.5
	return 0.0

## Executes the move
func execute() -> void:
	enemy.forced_movement_name = "DoNothing"
	enemy.forced_action_name = "ArrowShotPrecise"
	combat.animation.say(enemy.visual_entity, "Aiming for a precise shot...")
	combat.animation.effect(VFX.HEX_RINGS, enemy.visual_entity, {"color": Color.SLATE_GRAY}).set_flag_with()

