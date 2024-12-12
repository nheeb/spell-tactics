class_name VisualEntity extends Node3D

const HEALTH_BAR = preload("res://VFX/Effects/HealthBar/HealthBar3D.tscn")

var entity: Entity
var type: EntityType:
	get:
		return entity.type as EntityType
var entity_name: String:
	get:
		return str(entity)
var health_bar: HealthBar3D

@export_range(0, 360, 60) var visual_rotation: int:
	set(v):
		visual_rotation = v
		rotation_degrees.y = v

func _ready() -> void:
	pass

## This gets called in EntityType.setup_visuals()
func setup(ent: Entity):
	entity = ent
	visible = false
	# Create / Setup HealthBar
	if type.has_hp:
		if not has_node("HealthBar3D"):
			health_bar = HEALTH_BAR.instantiate()
			add_child(health_bar)
		else:
			health_bar = get_node("HealthBar3D") as HealthBar3D
			assert(health_bar)
		health_bar._ready()
		health_bar.position.y = type.hp_bar_height
		health_bar.visible = type.always_show_hp
		health_bar.update_hp(ent.hp, ent.max_hp, ent.armor)
	else:
		if has_node("HealthBar3D"):
			get_node("HealthBar3D").queue_free()

## Ticket Handler and getter for all kinds of animation
var ticket_handler := WaitTicketHandler.new()
func get_wait_ticket_handler() -> WaitTicketHandler:
	return ticket_handler

######################
## Basic animations ##
######################

## Base Movement (in seconds per tile)
var tile_speed := 0.5
## ANIM
func animation_move_to(tile: Tile) -> void:
	var ticket = ticket_handler.get_ticket()
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "global_position", tile.global_position, tile_speed)
	on_movement_visuals(tile)
	#tween.set_speed_scale(.05)
	await tween.finished
	ticket.resolve()

## ANIM
func animation_blink_to(tile: Tile) -> void:
	var ticket = ticket_handler.get_ticket()
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "scale", Vector3.ONE * .1, .4)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): global_position = tile.global_position)
	tween.tween_property(self, "scale", Vector3.ONE * 1.0, .4)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	ticket.resolve_on(tween.finished)
	var turn_tween := VisualTime.new_tween()
	turn_tween.tween_property(self, "rotation_degrees:y", \
			rotation_degrees.y + 360 * 3, .8)

############################
## Animations to override ##
############################

## ANIM
func on_movement_visuals(tile: Tile) -> void:
	# abstract, override for player/enemy
	pass

## ANIM
func on_hurt_visuals() -> void:
	# abstract, override for player/enemy
	pass

## ANIM
func on_death_visuals():
	hide()

const GREY_OUT_MAT: Material = preload("res://VFX/Materials/GreyOut3D.material")
## ANIM For overriding and making the drain effect
func visual_drain(drained := true):
	Audio.play("absorb")
	for child in Utility.get_recursive_mesh_instances(self):
		if child is MeshInstance3D:
			child = child as MeshInstance3D
			child.material_overlay = GREY_OUT_MAT
			var tween = VisualTime.new_tween()
			child.set_instance_shader_parameter("grey_out_progress", 0.0)
			tween.tween_property(child, "instance_shader_parameters/grey_out_progress", 1.0, VFX.DRAIN_DURATION)

####################
## Visual Effects ##
####################

var visual_effects := {}

func add_visual_effect(id: String, effect: StayingVisualEffect) -> void:
	if id in visual_effects:
		push_error("VisualEntity already has effect %s" % id)
	visual_effects[id] = effect
	add_child(effect)

func remove_visual_effect(id: String) -> void:
	if id in visual_effects.keys():
		var effect := (visual_effects[id] as StayingVisualEffect)
		ticket_handler.get_ticket().resolve_on(effect.effect_died)
		effect.on_effect_end()
		visual_effects.erase(id)
	else:
		push_error("VisualEntity has no effect %s" % id)

#########################
## Energy Orb Spawning ##
#########################

const ENERGY_ORB_ATTRACTOR = preload("res://VFX/Effects/EnergyOrbs/EnergyOrbAttractor.tscn")
const ENERGY_ORB = preload("res://VFX/Effects/EnergyOrbs/EnergyOrb.tscn")
const ORB_DELAY : float = .4
func spawn_energy_orbs(stack: EnergyStack, omb: OrbitalMovementBody):
	# Look for attractors
	var attractors : Array = get_children().filter( \
		func (c): return c is EnergyOrbAttractor)
	# TODO nitai add deeper search for attractor nodes in tree of vis entity
	# Add attractors if there are not enough for the stack
	while len(attractors) < stack.size():
		var new_at : EnergyOrbAttractor = VFX.ENERGY_ORB_ATTRACTOR.instantiate()
		add_child(new_at)
		attractors.append(new_at)
		new_at.position = Vector3(0,.7,0) + Utility.random_direction() * .4
		new_at.rotate(Vector3.FORWARD, (PI / 4) * randf())
		new_at.rotate(Vector3.UP, TAU * randf())
	attractors.shuffle()
	for i in range(stack.size()):
		await VisualTime.new_timer(ORB_DELAY).timeout
		var orb = VFX.ENERGY_ORB.instantiate()
		omb.add_child(orb)
		orb.type = stack.stack[i]
		orb._ready()
		orb.spawn(omb, attractors[i])
		
		
func look_at_tile(tile: Tile, ticket: WaitTicket):
	#var tween := VisualTime.create_tween()
	#var new_rotation_y: float = rotation_degrees.y + 60
	#tween.tween_property(self, "rotation_degrees:y", new_rotation_y, 0.35)
	#await tween.finished
	ticket.resolve()
