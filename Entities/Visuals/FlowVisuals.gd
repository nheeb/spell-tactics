@tool
class_name FlowVisuals extends VisualEntity

func on_death_visuals():
	hide()
	animation_done.emit()

## For overriding and making the drain effect
func visual_drain(drained := true):
	on_death_visuals()  # visuals should wholly disappear on drain
	animation_done.emit()
