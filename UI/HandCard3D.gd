class_name HandCard3D extends Card3D

var card_2d: HandCard2D

func _enter_tree() -> void:
	$Quad.get_surface_override_material(0).albedo_texture = $Quad/SubViewport.get_texture()
	%Cube.material_override.next_pass.set("shader_parameter/random_seed", randf())
	%Cube.material_override.next_pass.set("shader_parameter/card_texture", $TextureViewport.get_texture())
	%Cube.material_override.uv1_offset = Vector3(randf(), randf(), 0) * 10.0
	$Model/EnergySocketPivot/HandCardEnergySocket.queue_free()

func get_castable() -> Castable:
	return get_spell()

func get_spell() -> Spell:
	var spell =  $Quad/SubViewport/HandCard2D.spell
	return spell

func set_card(card: HandCard2D):
	card_2d = card
	$Quad/SubViewport.add_child(card)
	set_spell(card.spell)
	
func set_render_prio(p: int) -> void:
	$Quad.get_surface_override_material(0).set("render_priority", p)
	%Cube.material_override.set("render_priority", p)
	%Cube.material_override.next_pass.set("render_priority", p+1)

func set_collision_scale(s: float) -> void:
	$Area3D/CollisionShape3D.scale = Vector3.ONE * s

 
func set_spell(s: Spell) -> void:
	## TODO nitai remove card_2d
	#card_2d.set_spell(s)
	s.card = self
	set_spell_type(s.type)

const ENERGY_SOCKET = preload("res://UI/HandCards/HandCardEnergySocket.tscn")
func set_spell_type(type: SpellType) -> void:
	# Spawn Energy Sockets
	var costs : EnergyStack = type.costs
	for i in costs.size():
		var energy = costs.stack[i]
		var socket = ENERGY_SOCKET.instantiate()
		socket.card = self
		%EnergySocketPivot.add_child(socket)
		socket.position = get_energy_socket_pos(i, costs.size())
		socket.set_type(energy)
	# Set Texture
	%HandCardTexture.set_spell_type(type)
	# Set Shader color
	%Cube.material_override.next_pass.set("shader_parameter/albedo", type.color)

const ENERGY_SOCKET_DIST = .15
func get_energy_socket_pos(i: int, socket_count: int) -> Vector3:
	var middle : float = (socket_count-1) / 2.0
	return Vector3(0,0,1) * (float(i) - middle) * ENERGY_SOCKET_DIST

func get_empty_energy_socket(type : EnergyStack.EnergyType) -> HandCardEnergySocket:
	var socket_children := %EnergySocketPivot.get_children()
	socket_children.reverse()
	for c in socket_children:
		c = c as HandCardEnergySocket
		if c:
			if c.visible and (not c.is_loaded) and (not c.is_soon_loaded):
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

func set_pinned(s: bool):
	for c in %EnergySocketPivot.get_children():
		c = c as HandCardEnergySocket
		if c:
			c.set_hoverarble(s)


