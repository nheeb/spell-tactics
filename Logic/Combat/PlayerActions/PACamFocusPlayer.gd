class_name PACamFocusPlayer extends PlayerAction

func _init() -> void:
	action_string = "Camera Focus Player"
	blocking_types = [InputUtility.InputBlockType.EnemyPhase]

func execute(combat: Combat) -> void:
	combat.animation.camera_reach(combat.player.visual_entity).seperate_queue("cam")
