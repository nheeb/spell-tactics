class_name VisualTerrain extends VisualEntity

func visual_drain(drained := true):
	var tween = VisualTime.new_tween()
	tween.tween_property($Hexagon, "instance_shader_parameters/drain_progress", 1.0, VFX.DRAIN_DURATION)
