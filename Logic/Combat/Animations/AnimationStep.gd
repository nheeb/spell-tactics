class_name AnimationStep extends Object

signal step_done

var animations : Array[AnimationObject] = []

var relevant_animations_to_do := 0

func relevant_animation_done() -> void:
	relevant_animations_to_do -= 1
	if relevant_animations_to_do <= 0:
		step_done.emit()

func compile() -> void:
	for a in animations:
		if a.has_flag(AnimationObject.Flags.PlayAfterStep) or a.has_flag(AnimationObject.Flags.ExtendStep):
			relevant_animations_to_do += 1
			a.animation_done.connect(self.relevant_animation_done, CONNECT_ONE_SHOT)

func play(level: Level) -> void:
	for a in animations:
		#print(a)
		a._play(level)
	if relevant_animations_to_do == 0:
		step_done.emit()
