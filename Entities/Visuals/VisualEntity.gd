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

## For overriding and making the drain effect
func visual_drain(drained := true):
	pass

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
