class_name AnimationStep extends RefCounted

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

func play() -> void:
	for a in animations:
		a._play()
	if relevant_animations_to_do == 0:
		step_done.emit()
