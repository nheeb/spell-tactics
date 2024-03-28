#@tool
class_name VisualPlayer extends VisualEntity

@onready var anim_player := $MagicRaccoon_Model/MagicRaccoon/AnimationPlayer
@onready var anim_tree := $MagicRaccoon_Model/AnimationTree

func _ready() -> void:
	pass

func start_walking():
	anim_tree.anim_run()
	emit_animation_done_signal()
	
func go_idle():
	anim_tree.anim_idle()
	emit_animation_done_signal()
	
func start_casting():
	anim_tree.anim_cast_start()
	emit_animation_done_signal()

#func cast():
	## TODO
	#pass
	#emit_animation_done_signal()
	
func stop_casting():
	anim_tree.anim_cast_end()
	emit_animation_done_signal()

func on_movement_visuals(tile: Tile) -> void:
	# rotate player model so it faces the target tile
	var dir = self.global_position.direction_to(tile.global_position)
	rotate_y(basis.z.signed_angle_to(dir, Vector3.UP))
	
func on_hurt_visuals() -> void:
	anim_tree.anim_get_hit()
	emit_animation_done_signal()
	
func on_death_visuals() -> void:
	anim_tree.anim_death()
	await VisualTime.new_timer(4.5).timeout
	emit_animation_done_signal()
	

