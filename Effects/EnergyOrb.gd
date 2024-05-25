#@tool
class_name EnergyOrb extends Node3D

# see https://github.com/godotengine/godot/issues/4236
#var vfx_singleton = load("res://Effects/VFX.tscn").instantiate();

@export_enum("Any", "Matter", "Life", "Harmony", "Flow", "Decay", "Spectral") var type : int = 0:
	set(_type):
		type = _type
		$Orb.material_override.set("albedo_color", VFX.type_to_color(_type))
		$OmniLight3D.light_color = VFX.type_to_color(_type)
		$Orb.material_override.next_pass.set("shader_parameter/texture_albedo", \
							VFX.type_to_icon(_type))
@export var orbital_movement_active: bool = true
var in_ui := false

#func get_type():
	#return type

@onready var movement : OrbitalMovement = $OrbitalMovement

func spawn(orbit_body, attractor = null):
	movement.setup(attractor, orbit_body)
	$AnimationPlayer.play("spawn")

func spawn_in_ui(orbit_body, attractor = null):
	movement.setup(attractor, orbit_body)
	$AnimationPlayer.play("spawn_in_ui")
	in_ui = true
	%MouseArea.monitorable = true
	%MouseArea.monitoring = true
	$OmniLight3D.visible = false

func _ready() -> void:
	if orbital_movement_active:
		set_process(true)
	else:
		set_process(false)
	VisualTime.connect_animation_player($AnimationPlayer)
	%Outline.hide()

var ray_cast: RayCast3D
func _process(delta: float) -> void:
	movement.movement_process(delta * VisualTime.visual_time_scale)
	if in_ui:
		var hovered : bool = false
		if ray_cast:
			if ray_cast.get_collider() == %MouseArea:
				hovered = true
		%Outline.visible = hovered
		if hovered:
			if Input.is_action_just_pressed("select"):
				pass
				# TODO Pay

func death():
	$AnimationPlayer.play("death")

func delete():
	movement.detach_from_orbital_body()
	queue_free()
