extends Control

@onready var mesh2d : MeshInstance2D = $MeshInstance2D
@onready var base_scale : Vector2 = mesh2d.scale
@onready var icon_material : ShaderMaterial = mesh2d.material

var current_fill := 0
func set_fill(fill: int):
	current_fill = fill
	icon_material.set_shader_parameter("fill", fill)

func set_max_fill(max_fill: int):
	icon_material.set_shader_parameter("sections", max_fill)

func transition_to_fill(fill: int):
	var tween := VisualTime.new_tween()
	tween.tween_property(mesh2d, "scale", 1.4 * base_scale, .6)
	while current_fill != fill:
		if fill < current_fill:
			set_fill(0)
		else:
			set_fill(current_fill + 1)
		tween.tween_interval(.4)
	tween.tween_property(mesh2d, "scale", 1.0 * base_scale, .6)

func _ready() -> void:
	await get_tree().process_frame
	set_fill(0)
