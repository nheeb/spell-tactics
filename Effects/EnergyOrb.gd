#@tool
class_name EnergyOrb extends Node3D

# see https://github.com/godotengine/godot/issues/4236
#var vfx_singleton = load("res://Effects/VFX.tscn").instantiate();

#@export_enum("Any", "Matter", "Life", "Harmony", "Flow", "Decay", "Spectral") var type : int = 0:
@export var type : EnergyStack.EnergyType = EnergyStack.EnergyType.Any:
	set(_type):
		type = _type
		$Orb.material_override.set("albedo_color", VFX.type_to_color(_type))
		set_particles_color(VFX.type_to_color(_type))
		$OmniLight3D.light_color = VFX.type_to_color(_type)
		$Orb.material_override.next_pass.set("shader_parameter/texture_albedo", \
							VFX.type_to_icon(_type))
		$Visual/Icon.material_override.set("shader_parameter/texture_albedo", \
							VFX.type_to_icon(_type))
@export var orbital_movement_active: bool = true
var in_ui := false

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
	%MouseArea.collision_layer = 1
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
	if in_ui and hoverable:
		var hovered : bool = false
		if ray_cast:
			if ray_cast.get_collider() == %MouseArea:
				hovered = true
		%Outline.visible = hovered
		if hovered:
			if Input.is_action_just_pressed("select"):
				Events.energy_orb_clicked.emit(self)

var hoverable := true
func set_hoverable(h: bool):
	hoverable = h
	%MouseArea.monitorable = h
	%MouseArea.monitoring = h
	$MouseArea/CollisionShape3D.disabled = not h
	%Outline.visible = %Outline.visible and h

func death():
	$AnimationPlayer.play("death")

func delete():
	movement.detach_from_orbital_body()
	queue_free()
	
func set_render_priority(render_prio: int):  # used in ui to draw orbs behind cards
	$Orb.material_override.render_priority = render_prio


func set_particles_color(color: Color):
	var color_base = color * 1.2
	var color_glow = color * 1.6
	var color_dark = color.darkened(.3) * 1.2
	var color_bright = color.lightened(.8) * 2.0
	color_base.a = color.a
	color_glow.a = color.a
	color_dark.a = color.a
	color_bright.a = color.a
	$Visual/Rings.draw_pass_1.material.albedo_color = color_glow
	$Visual/Core.draw_pass_1.material.albedo_color = color_dark
	$Visual/Energy.draw_pass_1.material.albedo_color = color_glow
	$Visual/Sparks.draw_pass_1.material.albedo_color = color_bright
	$Visual/Particles.draw_pass_1.material.albedo_color = color_bright
