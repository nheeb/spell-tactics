extends EnemyActionLogic

const STATUS_SHOT_CHARGED = preload(
	"res://Spells/AllStatusEffects/EnemyMoves/ShotCharged.tres"
)

func _execute():
	enemy.apply_status(STATUS_SHOT_CHARGED, 
		{"_targets": [target_entity.get_reference()]}
	)
