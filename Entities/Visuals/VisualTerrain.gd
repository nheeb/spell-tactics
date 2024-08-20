
class_name VisualTerrain extends VisualEntity

@export var drain_visuals_duration := 0.8

func visual_drain(drained := true):
	var tween = VisualTime.new_tween()
	tween.tween_property($Hexagon, "instance_shader_parameters/drain_progress", 1.0, VFX.DRAIN_DURATION)

	
