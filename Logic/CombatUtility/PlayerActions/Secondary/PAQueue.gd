class_name PAQueue extends PlayerAction

var queue : Array[PlayerAction] = []
var wait_for_animations := true

func _init(_queue = [], _wait_for_animations := false) -> void:
	queue = _queue
	wait_for_animations = _wait_for_animations
	var q_string = queue.reduce(func(x, y): return str(x) + "," + str(y), "")
	action_string = "Player Action Queue [[%s]]" % q_string

func is_valid(combat: Combat) -> bool:
	return true

func execute(combat: Combat) -> void:
	for pa in queue:
		combat.input.process_action(pa, true)
		if wait_for_animations:
			if combat.animation.is_playing():
				await combat.animation.animation_queues_empty

func on_fail(combat: Combat) -> void:
	pass

