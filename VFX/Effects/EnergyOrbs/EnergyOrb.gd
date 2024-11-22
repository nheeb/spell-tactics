class_name EnergyOrb extends Node3D

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
		$Visual/LabelSymbol.text = EnergyStack.ENERGY_TO_SYMBOL[_type]
		$Visual/LabelSymbol.offset.x = 0
		$Visual/LabelNumber.visible = false
@export var energy_count := 1:
	set(count):
		energy_count = count
		if energy_count_progress:
			energy_count_progress.reach(energy_count)
var energy_count_progress: VisualTime.VisualProgress

@export var orbital_movement_active: bool = true
var in_ui := false
var base_scale := 1.0
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
	energy_count_progress = VisualTime.new_progress(1.0, 1.5)
	energy_count_progress.connect_to(_energy_count_progress)

func spawn_in_ui_split():
	movement.setup(null, null)
	$AnimationPlayer.play("spawn_in_ui_split")
	in_ui = true
	%MouseArea.monitorable = false
	%MouseArea.monitoring = false
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

func add_to_render_prio(x: int):
	$Visual/Rings.draw_pass_1.material.render_priority += x
	$Visual/Core.draw_pass_1.material.render_priority += x
	$Visual/Energy.draw_pass_1.material.render_priority += x
	$Visual/Sparks.draw_pass_1.material.render_priority += x
	$Visual/Particles.draw_pass_1.material.render_priority += x
	$Visual/Icon.material_override.render_priority += x
	$Visual/LabelNumber.render_priority += x
	$Visual/LabelSymbol.render_priority += x

const SYMBOL_OFFSET = 36
func _energy_count_progress(progress: float):
	progress = int(progress) + ease(fmod(progress, 1.0), -2.0)
	var size := Utility.clamp_map(progress, 1.0, 6.0, .9, 1.55)
	var label_number := int(progress + .5)
	var label_text := "" if label_number <= 1 else str(label_number)
	var symbol_offset := 0#Utility.clamp_map(progress, 1.0, 1.8, 0.0, 1.0) * SYMBOL_OFFSET
	var label_size := Utility.clamp_map(
		abs(progress - int(progress) - .5), .0, .4, .1, 1.0
	)
	scale = Vector3.ONE * size * base_scale
	$Visual/LabelNumber.text = label_text
	$Visual/LabelNumber.visible = label_text != null
	$Visual/LabelNumber.scale = Vector3.ONE * label_size
	$Visual/LabelSymbol.offset.x = symbol_offset

func create_single_orb() -> EnergyOrb:
	assert(in_ui)
	var split: EnergyOrb = VFX.ENERGY_ORB.instantiate()
	split._ready()
	split.type = type
	split.spawn_in_ui_split()
	get_parent().add_child(split)
	split.base_scale = self.base_scale
	split.global_position = self.global_position
	split._energy_count_progress(1.0)
	return split
