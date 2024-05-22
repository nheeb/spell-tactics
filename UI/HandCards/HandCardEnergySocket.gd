extends Node3D

@onready var socket : MeshInstance3D = $EnergySocket/Socket

var energy_color : Color

func _ready() -> void:
	pass

func set_type(type: EnergyStack.EnergyType):
	_ready()
	var mi : MeshInstance3D = %EnergySocket.get_node(EnergyStack.type_to_str(type)) as MeshInstance3D
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

