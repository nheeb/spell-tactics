@tool
class_name VisualEntity extends Node3D

# Here we could define some common callbacks / signals that other VisualEntities inheriting
# from this could use

## reference to the resource could be needed for variety of effects 
## (e.g. in VisualPrototype for the name)
var type: EntityType
var entity: Entity

func _enter_tree() -> void:
	if has_node("DebugTile"):
		$DebugTile.visible = false

signal animation_done

var tile_speed := 0.5  # s per tile
func animation_move_to(tile: Tile) -> void:
	var tween := VisualTime.new_tween()
	tween.tween_property(self, "global_position", tile.global_position, tile_speed)
	on_movement_visuals(tile)
	#tween.set_speed_scale(.05)
	await tween.finished
	animation_done.emit()
	
func on_movement_visuals(tile: Tile) -> void:
	# abstract, override for player/enemy
	animation_done.emit()

func on_hurt_visuals() -> void:
	# abstract, override for player/enemy
	animation_done.emit()

func on_death_visuals():
	hide()
	animation_done.emit()

## For overriding and making the drain effect
func visual_drain(drained := true):
	animation_done.emit()

var visual_effects := {}

func add_visual_effect(id: String, effect: StayingVisualEffect) -> void:
	if id in visual_effects:
		printerr("VisualEntity already has effect %s" % id)
	visual_effects[id] = effect
	add_child(effect)

func remove_visual_effect(id: String) -> void:
	if id in visual_effects.keys():
		var effect := (visual_effects[id] as StayingVisualEffect)
		effect.effect_died.connect(emit_animation_done_signal, CONNECT_ONE_SHOT)
		effect.on_effect_end()
		visual_effects.erase(id)
	else:
		printerr("VisualEntity has no effect %s" % id)
		animation_done.emit()

func emit_animation_done_signal():
	animation_done.emit()

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
		orb.set_type(stack.stack[i])
		orb._ready()
		orb.spawn(omb, attractors[i])
