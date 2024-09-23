class_name EnemyEventIcon extends Control

var current_event: EnemyEvent

@onready var inactive_mesh: MeshInstance2D = %InactiveMesh
@onready var active_mesh: MeshInstance2D = %ActiveMesh
#@onready var mesh2d : MeshInstance2D = $MeshInstance2D
@onready var icon_material : ShaderMaterial = inactive_mesh.material
@onready var pivot: Node2D = %Pivot
var base_scale := Vector2.ONE

var current_fill := 0
func set_fill(fill: int, tween: Tween = null):
	current_fill = fill
	if tween:
		tween.tween_callback(icon_material.set_shader_parameter.bind("fill", fill))
	else:
		icon_material.set_shader_parameter("fill", fill)

func set_event(event: EnemyEvent):
	current_event = event
	if event:
		set_max_fill(event.get_enemy_meter_costs())
		set_fill(0)
		inactive_mesh.texture = event.get_inactive_icon()
		active_mesh.texture = event.get_active_icon()

func set_max_fill(max_fill: int):
	pivot.visible = max_fill > 0
	icon_material.set_shader_parameter("sections", max_fill)

signal transition_done
func transition_to_fill(fill: int):
	var tween := VisualTime.new_tween()
	while current_fill != fill:
		if fill < current_fill:
			set_fill(0, tween)
		else:
			set_fill(current_fill + 1, tween)
		tween.tween_property(pivot, "scale", 1.3 * base_scale, .2)
		tween.tween_property(pivot, "scale", base_scale, .4)
	await tween.finished
	transition_done.emit()

func _ready() -> void:
	await get_tree().process_frame
	set_fill(0)

func _on_area_2d_mouse_entered() -> void:
	if current_event:
		current_event.hover()

func _on_area_2d_mouse_exited() -> void:
	if current_event:
		current_event.hover(false)

func spawn():
	%AnimationPlayer.play("spawn")

func activate():
	%AnimationPlayer.play("activate")

func clear():
	%AnimationPlayer.play("clear")
