extends Node3D

@onready var bar: Panel = $SubViewport/HealthBar2D.get_node("%Bar")
@onready var container: Container = $SubViewport/HealthBar2D.get_node("%Container")

@export var hp: int = 0
@export var max_hp: int = 0
@export var shield: int = 0

@export var highlight_progress: Curve
@export var hp_progress: Curve

@export var base_cell_width_px := 50.0

func _enter_tree() -> void:
	$HealthbarQuad.get_active_material(0).albedo_color = Color.WHITE 	# was transparent for editor beauty ;)
	$HealthbarQuad.get_active_material(0).albedo_texture = $SubViewport.get_texture()
	

const BORDER_WIDTH := 30.0;
const MAX_WIDTH := 1080.0;
# max width should be reached once we have 5 cells in the bar
const DEFAULT_CELL_WIDTH := (MAX_WIDTH - 2 * BORDER_WIDTH) / 5.0;
func update_container_offsets():  # cells ~= max_hp
	# make healthbar different widths depending on number of cells
	var number_of_cells = max_hp + shield
	var total_width = min(MAX_WIDTH, number_of_cells * DEFAULT_CELL_WIDTH)
	var width_diff_halved = (MAX_WIDTH - total_width) / 2.0
	
	print("width for ", get_parent().entity_name, " = ", width_diff_halved)
	container.offset_left = width_diff_halved
	container.offset_right = -width_diff_halved
	
func update_hp(hp_new, max_hp_new, shield_new):
	#print("UPDATE HP ", hp_new)
	# determine whether any animation should play, these are responsible for affecting
	# the shader parameters
	if max_hp == max_hp_new:
		if hp_new < hp or shield_new < shield:
			# got dealt damage
			var total_difference = max(shield - shield_new, 0) + max(hp - hp_new, 0)
			damage_by(total_difference)
		if hp_new > hp:
			# got healed
			heal_by(hp_new - hp)
		if shield_new > shield:
			# got shielded
			shield_by(shield_new - shield)
	else:
		# (re-)initialize everything, play no animation
		#print("setting up ", get_parent().entity_name, " hp = ", hp_new, " / ", max_hp_new)
		bar.material.set_shader_parameter("health", hp_new)
		bar.material.set_shader_parameter("shield", shield_new)
		bar.material.set_shader_parameter("max_health", max_hp_new)
		bar.material.set_shader_parameter("target_health", 0.0)
	
	# apply logical state
	self.hp = hp_new
	self.max_hp = max_hp_new
	self.shield = shield_new
	
	#update_container_offsets()




var start_health: float
var target_health: float
func sample_health(x: float):  # helper method for tweening
	var t: float = hp_progress.sample(x)
	var health_t = t * start_health + (1.0 - t) * target_health
	bar.material.set("shader_parameter/health", health_t)

const HIT_DURATION = 0.75
func damage_by(damage: int):
	target_health = float(hp) + float(shield) - float(damage)
	start_health = float(hp)
	#print("shader health before ", bar.material.get("shader_parameter/health"))

	var tween = VisualTime.new_tween()
	if damage <= shield:
		# just shield highlighting
		bar.material.set("shader_parameter/shield", shield - damage)
	else:
		if shield > 0:
			# mixed highlighting
			bar.material.set("shader_parameter/shield", 0.0)
			
		#  health highlighting
		bar.material.set("shader_parameter/target_health", target_health)
		tween.tween_method(sample_health, 0.0, 1.0 , HIT_DURATION)
		tween.parallel().tween_method(func(x): bar.material.set("shader_parameter/highlight_progress", highlight_progress.sample(x)), 0.0, 1.0, HIT_DURATION)
	await VisualTime.new_timer(HIT_DURATION / 2.0).timeout
	await tween.finished

	bar.material.set("shader_parameter/highlight_progression", 0.0)
	

func shield_by(by: int):
	print("shield by ", by)
	bar.material.set_shader_parameter("shield", shield + by)
	
func heal_by(heal: int):
	print("heal %s by %d" % [get_parent().entity_name, heal])
	var old_hp = bar.material.get_shader_parameter("health")
	bar.material.set_shader_parameter("health", old_hp + heal)
