class_name HandCardEnergySocket extends Node3D

signal loaded

@onready var socket : MeshInstance3D = $EnergySocket/Socket

var card: HandCard3D

var energy_color : Color
var inner_color : Color
var mi : MeshInstance3D
var type : EnergyStack.EnergyType

func _ready() -> void:
	%Light.hide()
	set_hoverarble(false)
	%Outline.hide()

func set_type(_type: EnergyStack.EnergyType):
	type = _type
	_ready()
	mi = %EnergySocket.get_node(EnergyStack.type_to_str(type)) as MeshInstance3D
	if not mi:
		push_error("Energy Socket Mesh not found")
		return
	
	for c in %EnergySocket.get_children():
		c.hide()
	
	socket.show()
	mi.show()
	
	mi.material_override = %MaterialPrototype.material_override
	energy_color = VFX.type_to_color(type)
	inner_color = VFX.type_to_inner_color(type)
	mi.material_override.albedo_color = inner_color
	mi.material_override.emission = inner_color
	mi.material_override.emission_energy_multiplier = 1
	socket.get_surface_override_material(0).albedo_color = energy_color.lerp(Color.BLACK, .25)
	socket.get_surface_override_material(1).albedo_color = Color.WHITE.lerp(Color.BLACK, .8)
	socket.get_surface_override_material(1).emission_energy_multiplier = 0
	socket.get_surface_override_material(2).albedo_color = energy_color.lerp(Color.WHITE_SMOKE, .05)

var is_loaded := false
var loaded_energy: EnergyStack.EnergyType
var loaded_color: Color
func load_energy(_type: EnergyStack.EnergyType):
	is_loaded = true
	loaded_energy = _type
	loaded_color = VFX.type_to_color(_type)
	card.get_castable().on_energy_load()

## ANIM
func load_animation(_type: EnergyStack.EnergyType):
	loaded_color = VFX.type_to_color(_type)
	%Light.light_color = loaded_color.lerp(Color.WHITE, .4)
	%Light.show()
	mi.material_override.albedo_color = loaded_color.lerp(Color.DARK_GRAY, .2)
	mi.material_override.emission = loaded_color
	mi.material_override.emission_energy_multiplier = 2
	socket.get_surface_override_material(1).albedo_color = loaded_color.lerp(Color.DARK_GRAY, .2)
	socket.get_surface_override_material(1).emission = loaded_color
	socket.get_surface_override_material(1).emission_energy_multiplier = 2.2
	%AnimationPlayer.play("load")

func pre_load_particles(_type: EnergyStack.EnergyType, seconds_to_load: float):
	%GlowParticles.draw_pass_1.material.albedo_color = VFX.type_to_color(_type).lightened(.15) * 2.0
	VisualTime.new_timer(max(0.0, seconds_to_load - .44)).timeout.connect(%GlowParticles.restart)

func unload_energy() -> EnergyStack.EnergyType:
	is_loaded = false
	var e := loaded_energy
	loaded_energy = EnergyStack.EnergyType.Empty
	card.get_spell().on_energy_load()
	return e

var last_prio := 0
var all_mesh_instances: Array[MeshInstance3D]
func set_render_prio(p: int) -> void:
	if p == last_prio:
		return
	last_prio = p
	if all_mesh_instances.is_empty():
		all_mesh_instances = Utility.get_recursive_mesh_instances(self)
	for mesh_instance in all_mesh_instances:
		if mesh_instance.material_override:
			mesh_instance.material_override.render_priority = p
		for i in mesh_instance.get_surface_override_material_count():
			var mat := mesh_instance.get_surface_override_material(i)
			if mat:
				mat.render_priority = p

## ANIM 
func unload_animation():
	%Light.hide()
	mi.material_override.albedo_color = inner_color
	mi.material_override.emission = inner_color
	mi.material_override.emission_energy_multiplier = 1
	socket.get_surface_override_material(1).albedo_color = Color.WHITE.lerp(Color.BLACK, .8)
	socket.get_surface_override_material(1).emission_energy_multiplier = 0

var hoverable := false
func set_hoverarble(h: bool):
	hoverable = h
	%HoverArea.monitorable = h
	%HoverArea.monitoring = h
	%HoverAreaCollisionShape.disabled = not h

var ray_cast: RayCast3D
func _process(delta: float) -> void:
	if hoverable:
		var hovered : bool = false
		if ray_cast:
			if ray_cast.get_collider() == %HoverArea:
				hovered = true
		%Outline.visible = hovered
		if hovered:
			if Input.is_action_just_pressed("select"):
				Events.energy_socket_clicked.emit(self)
