@tool
class_name VisualEntity extends Node3D

# Here we could define some common callbacks / signals that other VisualEntities inheriting
# from this could use

## reference to the resource could be needed for variety of effects 
## (e.g. in VisualPrototype for the name)
var type: EntityType
var entity: Entity

@onready var entity_name = str(entity.id) if entity != null else "null_entity"

func _enter_tree() -> void:
	if has_node("DebugTile"):
		$DebugTile.visible = false

var ticket_handler := WaitTicketHandler.new()
func get_wait_ticket_handler() -> WaitTicketHandler:
	return ticket_handler

var tile_speed := 0.5  # s per tile
func animation_move_to(tile: Tile) -> void:
	var ticket = ticket_handler.get_ticket()
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "global_position", tile.global_position, tile_speed)
	on_movement_visuals(tile)
	#tween.set_speed_scale(.05)
	await tween.finished
	ticket.resolve()

func animation_blink_to(tile: Tile) -> void:
	var ticket = ticket_handler.get_ticket()
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "scale", Vector3.ONE * .1, .3)\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(func(): global_position = tile.global_position)
	tween.tween_property(self, "scale", Vector3.ONE * 1.0, .3)\
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	ticket.resolve_on(tween.finished)
	var turn_tween := VisualTime.new_tween()
	turn_tween.tween_property(self, "rotation_degrees:y", \
			rotation_degrees.y + 360 * 2, .6)

func on_movement_visuals(tile: Tile) -> void:
	# abstract, override for player/enemy
	pass

func on_hurt_visuals() -> void:
	# abstract, override for player/enemy
	pass

func on_death_visuals():
	hide()
	pass

## For overriding and making the drain effect
const GREY_OUT_MAT: Material = preload("res://Effects/GreyOut3D.material")
func visual_drain(drained := true):
	for child in Utility.get_recursive_mesh_instances(self):
		if child is MeshInstance3D:
			child = child as MeshInstance3D
			child.material_overlay = GREY_OUT_MAT
			var tween = VisualTime.new_tween()
			child.set_instance_shader_parameter("grey_out_progress", 0.0)
			tween.tween_property(child, "instance_shader_parameters/grey_out_progress", 1.0, VFX.DRAIN_DURATION)

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

const ENERGY_ORB_ATTRACTOR = preload("res://Effects/EnergyOrbs/EnergyOrbAttractor.tscn")
const ENERGY_ORB = preload("res://Effects/EnergyOrb.tscn")
const ORB_DELAY : float = .7
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
