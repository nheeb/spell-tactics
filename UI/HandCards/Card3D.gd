class_name Card3D extends Node3D

@onready var smooth_movement: SmoothMovement = $SmoothMovement
@onready var card_model: MeshInstance3D = %CardModel
@onready var card_texture: CardTexture = %CardTexture


func _enter_tree() -> void:
	%CardModel.material_override.next_pass.set("shader_parameter/random_seed", randf())
	%CardModel.material_override.next_pass.set("shader_parameter/card_texture", $TextureViewport.get_texture())
	%CardModel.material_override.uv1_offset = Vector3(randf(), randf(), 0) * 10.0
	$Model/EnergySocketPivot/HandCardEnergySocket.queue_free()

func _ready() -> void:
	pass

#########################
## Associated Castable ##
#########################

var castable: Castable
var spell: Spell:
	get:
		return castable as Spell
var active: Active:
	get:
		return castable as Active

func get_castable() -> Castable:
	return castable

func get_spell() -> Spell:
	return spell

func get_active() -> Active:
	return active

func set_spell(s: Spell) -> void:
	castable = s
	s.card = self
	set_castable_type(s.type)

func set_active(a: Active) -> void:
	castable = a
	a.card = self
	set_castable_type(a.type)

const ENERGY_SOCKET = preload("res://UI/HandCards/HandCardEnergySocket.tscn")
func set_castable_type(type: CastableType) -> void:
	# Spawn Energy Sockets
	var costs : EnergyStack = type.costs
	costs.sort()
	for i in costs.size():
		var energy = costs.stack[i]
		var socket = ENERGY_SOCKET.instantiate()
		socket.card = self
		%EnergySocketPivot.add_child(socket)
		socket.position = get_energy_socket_pos(i, costs.size())
		socket.set_type(energy)
	# Set Texture
	%CardTexture._ready()
	%CardTexture.set_castable_type(type)

func set_miniature_variant_energy_type(et: EnergyStack.EnergyType):
	# Set Texture
	%CardTexture.set_miniature_variant_energy_type(et)
	# Set Shader color
	# TODO Nils fix this
	#%CardModel.material_override.next_pass \
		#.set("shader_parameter/albedo", VFX.type_to_color(et))
	set_distort(false)

####################
## Energy Sockets ##
####################

const ENERGY_SOCKET_DIST = .15
func get_energy_socket_pos(i: int, socket_count: int) -> Vector3:
	var middle : float = (socket_count-1) / 2.0
	return Vector3(0,0,1) * (float(i) - middle) * ENERGY_SOCKET_DIST

func get_loaded_energy_sockets() -> Array[HandCardEnergySocket]:
	var a: Array[HandCardEnergySocket] = []
	var socket_children := %EnergySocketPivot.get_children()
	a.append_array(socket_children.filter(
		func (s):
			return s is HandCardEnergySocket and s.is_loaded and s.visible
	))
	return a

func get_empty_energy_socket(type : EnergyStack.EnergyType) -> HandCardEnergySocket:
	if type == EnergyStack.EnergyType.Spectral:
		type = EnergyStack.EnergyType.Any
	var socket_children := %EnergySocketPivot.get_children()
	socket_children.reverse()
	for c in socket_children:
		c = c as HandCardEnergySocket
		if c:
			if c.visible and (not c.is_loaded):
				if type == EnergyStack.EnergyType.Any:
					return c
				elif c.type == EnergyStack.EnergyType.Any:
					return c
				elif type == c.type:
					return c
	return null

func unload_all_sockets() -> Array[EnergyStack.EnergyType]:
	var energy : Array[EnergyStack.EnergyType] = []
	for c in %EnergySocketPivot.get_children():
		c = c as HandCardEnergySocket
		if c:
			if c.is_loaded:
				energy.append(c.unload_energy())
	return energy

func get_loaded_energy() -> EnergyStack:
	var energy : Array[EnergyStack.EnergyType] = []
	for c in %EnergySocketPivot.get_children():
		c = c as HandCardEnergySocket
		if c:
			if c.is_loaded:
				energy.append(c.loaded_energy)
	return EnergyStack.new(energy)

func has_empty_energy_sockets() -> bool:
	return get_empty_energy_socket(EnergyStack.EnergyType.Any) != null

############################
## Cards UI & VFX Methods ##
############################

func set_render_prio(p: int) -> void:
	%CardModel.material_override.set("render_priority", p)
	if %CardModel.material_overlay:
		%CardModel.material_overlay.set("render_priority", p-1)
	%CardModel.material_override.next_pass.set("render_priority", p+1)

	for socket in %EnergySocketPivot.get_children():
		if socket is HandCardEnergySocket:
			socket.set_render_prio(p+1)

func set_collision_scale(s: float) -> void:
	$Area3D/CollisionShape3D.scale = Vector3.ONE * s

func set_pinned(s: bool):
	for c in %EnergySocketPivot.get_children():
		c = c as HandCardEnergySocket
		if c:
			c.set_hoverarble(s)

const HOVER_MAT = preload("res://VFX/Materials/HandCardHover.tres")
func hover():
	%CardModel.material_overlay = HOVER_MAT
	
func unhover():
	%CardModel.material_overlay = null

func warp(pos: Vector3 = %IconOrigin.global_position):
	RenderingServer.global_shader_parameter_set("card_warp_origin", pos)
	# TODO reimplement card warp
	#VisualTime.new_tween().tween_property(card_model.material_override.next_pass, \
				#"shader_parameter/warp_progress", 2.0, 1.4).from(0.0)

func set_glow(g : bool):
	# TODO reimplement card glow
	#VisualTime.new_tween().tween_property(card_model.material_override.next_pass, \
						#"shader_parameter/glow_process", 1.0 if g else 0.0, .3)
	pass

const MAX_DISTORT := 0.81
func set_distort(d : bool):
	VisualTime.new_tween().tween_property( \
						card_texture.icon_texture.main_icon.material, \
						"shader_parameter/distort_progress", MAX_DISTORT if d else 0.0, .45)
