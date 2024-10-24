extends EnemyActionLogic

const STATUS_PUNCH_CHARGED = preload(
	"res://Spells/AllStatusEffects/EnemyMoves/RocketPunchCharged.tres"
)

func _execute():
	enemy.apply_status(
		STATUS_PUNCH_CHARGED, 
		{"_targets": [target_entity.get_reference()]}
	)
