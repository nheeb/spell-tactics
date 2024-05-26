@tool
class_name VisualPlayer extends VisualEntity

@onready var anim_player := $MagicRaccoon_Model/MagicRaccoon/AnimationPlayer
@onready var anim_tree := $MagicRaccoon_Model/AnimationTree

@export_range(0.0, 1.0) var idle_break_chance := 1.0

@onready var orbital_movement_body : OrbitalMovementBody = $OrbitalMovementBody

func _ready() -> void:
	pass

func _enter_tree() -> void:
	$HealthbarQuad.get_active_material(0).albedo_color = Color.WHITE 	# was transparent for editor beauty ;)
	$HealthbarQuad.get_active_material(0).albedo_texture = $SubViewport.get_texture()

func start_walking():
	anim_tree.anim_run()
	emit_animation_done_signal()
	
func go_idle():
	anim_tree.anim_idle()
	emit_animation_done_signal()
	
func start_casting():
	anim_tree.anim_cast_start()
	emit_animation_done_signal()

func stop_casting():
	anim_tree.anim_cast_end()
	emit_animation_done_signal()

# the animation (start_walking) gets called from outside (PlayerMovement.gd)
func on_movement_visuals(tile: Tile) -> void:
	# rotate player model so it faces the target tile
	var movement_direction = global_position.direction_to(tile.global_position)
	var relative_forward: Vector3 = -basis.z
	
	# rotate by difference between forward direction and movement direction
	rotate_y(relative_forward.signed_angle_to(movement_direction, Vector3.UP))
	
func on_hurt_visuals() -> void:
	anim_tree.anim_get_hit()
	emit_animation_done_signal()
	
func on_death_visuals() -> void:
	anim_tree.anim_death()
	await VisualTime.new_timer(4.5).timeout
	emit_animation_done_signal()
	


func start_idling():
	$IdleBreakChance.start()
	emit_animation_done_signal()
	
func stop_idling():
	$IdleBreakChance.stop()
	emit_animation_done_signal()


func _on_idle_break_chance_timeout() -> void:
	if randf() < idle_break_chance:
		anim_tree.anim_idle_break()
		
func update_hp(hp, armor, max_hp):
	$SubViewport/HealthBar2D.set_hp(hp, armor, max_hp)
