class_name Card3D extends Node3D

@onready var smooth_movement: SmoothMovement = $SmoothMovement
@onready var card_model: MeshInstance3D = %CardModel
@onready var card_texture: CardTexture = %CardTexture

func _ready() -> void:
	pass

func get_loaded_energy_sockets() -> Array[HandCardEnergySocket]:
	var a: Array[HandCardEnergySocket] = []
	return a

func get_empty_energy_socket(type : EnergyStack.EnergyType) -> HandCardEnergySocket:
	return null

func has_empty_energy_sockets() -> bool:
	return get_empty_energy_socket(EnergyStack.EnergyType.Any) != null

func get_loaded_energy() -> EnergyStack:
	return EnergyStack.new()

func get_castable() -> Castable:
	return null

func set_pinned(s: bool):
	pass

func warp(pos: Vector3 = %IconOrigin.global_position):
	RenderingServer.global_shader_parameter_set("card_warp_origin", pos)
	VisualTime.new_tween().tween_property(card_model.material_override.next_pass, \
				"shader_parameter/warp_progress", 2.0, 1.4).from(0.0)

func set_glow(g : bool):
	VisualTime.new_tween().tween_property(card_model.material_override.next_pass, \
						"shader_parameter/glow_process", 1.0 if g else 0.0, .3)

func set_distort(d : bool):
	VisualTime.new_tween().tween_property( \
						card_texture.icon_texture.main_icon.material, \
						"shader_parameter/distort_progress", 1.0 if d else 0.0, .45)

