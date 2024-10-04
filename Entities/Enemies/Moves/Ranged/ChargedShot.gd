extends EnemyActionLogic

# args: EnemyActionArgs
# action: EnemyAction
# combat: Combat
# enemy: EnemyEntity
# plan: EnemyActionPlan
# target

const STATUS_SHOT_CHARGED = preload(
	"res://Spells/AllStatusEffects/EnemyMoves/ShotCharged.tres"
)

func _execute():
	enemy.apply_status(STATUS_SHOT_CHARGED, 
		{"_targets": [target_entity.get_reference()]}
	)

func _is_possible(enemy_tile: Tile) -> bool:
	return true
