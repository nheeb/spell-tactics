class_name HandCardEnergySocket extends Node3D

@onready var socket : MeshInstance3D = $EnergySocket/Socket

var energy_color : Color
var mi : MeshInstance3D

func _ready() -> void:
	%Light.hide()

func set_type(type: EnergyStack.EnergyType):
	_ready()
	mi = %EnergySocket.get_node(EnergyStack.type_to_str(type)) as MeshInstance3D
	if not mi:
		printerr("Energy Socket Mesh not found")
		return
	
	for c in %EnergySocket.get_children():
		c.hide()
	
	socket.show()
	mi.show()
	
	mi.material_override = %MaterialPrototype.material_override
	energy_color = VFX.type_to_color(type)
	mi.material_override.albedo_color = energy_color.lerp(Color.DARK_GRAY, .1)
	mi.material_override.emission = energy_color
	mi.material_override.emission_energy_multiplier = 1
	socket.get_surface_override_material(2).albedo_color = energy_color.lerp(Color.DARK_GRAY, .4)

var is_loaded := false
var loaded_energy: EnergyStack.EnergyType
var loaded_color: Color
func load_energy(type: EnergyStack.EnergyType):
	is_loaded = true
	loaded_energy = type
	loaded_color = VFX.type_to_color(type)
	%Light.light_color = loaded_color
	%Light.show()
	mi.material_override.albedo_color = loaded_color.lerp(Color.DARK_GRAY, .1)
	mi.material_override.emission = loaded_color
	mi.material_override.emission_energy_multiplier = 2
	%AnimationPlayer.play("load")

func unload_energy() -> EnergyStack.EnergyType:
	is_loaded = false
	%Light.hide()
	mi.material_override.albedo_color = energy_color.lerp(Color.DARK_GRAY, .1)
	mi.material_override.emission = energy_color
	mi.material_override.emission_energy_multiplier = 1
	return loaded_energy
