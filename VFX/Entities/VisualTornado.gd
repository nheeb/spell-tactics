extends VisualEntity

@export var rings: int = 1
@export var balls: int = 1
@export var balls_increment: int = 1
@export var radius: float = 1
@export var radius_increment: float = 1
@export var ring_divider: int = 5
@export var radius_increment_large: float = 1
@export var size: float = 1
@export var size_per_ring: float = 1
@export var color_variation: float = 0.2
@export var ring_height_distance: float = 1
@export var rotation_speed: float = 1
@export var ring_speed_range: float = 0.75
@export var ring_horizontal_displacement_range: float = 1
@export var ring_horizontal_displacement_duration: float = 1.5
@export var ball_size_variation: float = 0.12
@export var ball_size_animation_range: float = 0.50
@export var ball_size_animation_duration: float = 2
@export var color_darkest = Color(0,0,0)
@export var color_lightest = Color(0.6,0.6,0.6)
@export var gap_chance: float = 0.005

class BallProperties:
	var ref: Node3D
	var start_scale: float
	var end_scale: float
	var scale_duration: float

class RingProperties:
	var ref: Node3D
	var rotation_speed: float
	# horizontal displacement
	var hd_start: float
	var hd_end: float
	var hd_duration: float

func spawn_sphere(location, size, parent):
	if randf()<gap_chance:
		return
	var material = StandardMaterial3D.new()
	material.albedo_color = color_darkest.lerp(color_lightest, randf())

	var models = [
		preload("res://Assets/Models/VFX/asymmetric-sphere-1.glb"),
		preload("res://Assets/Models/VFX/asymmetric-sphere-2.glb"),
	]
	var model = models.pick_random()
	var sphere = model.instantiate()
	sphere.get_child(0).set_surface_override_material(0, material)
	sphere.translate(location)
	sphere.rotate_x(randf())
	sphere.rotate_y(randf())
	sphere.rotate_z(randf())
	parent.add_child(sphere)

	var start_size = size+size*randf_range(-ball_size_variation, ball_size_variation)
	sphere.scale = v3(start_size)
	var end_size = start_size + size*randf_range(-ball_size_animation_range, ball_size_animation_range)
	var bp = BallProperties.new()
	bp.ref = sphere
	bp.start_scale=start_size
	bp.end_scale=end_size
	bp.scale_duration= ball_size_animation_duration
	the_balls.append(bp)

var ring_parents = []
var the_balls = []

func spawn_ring(ring, displacement):
	var parent = Node3D.new()
	var rp = RingProperties.new()
	rp.ref = parent
	rp.rotation_speed = randf_range(-ring_speed_range, ring_speed_range)*rotation_speed
	rp.hd_start = 0
	rp.hd_end = randf_range(-ring_horizontal_displacement_range, ring_horizontal_displacement_range)
	if ring == 0:
		rp.hd_end = 0
	rp.hd_duration = ring_horizontal_displacement_duration
	ring_parents.append(rp)
	self.add_child(parent)
	var spheres = balls + balls_increment*ring
	var r:float
	if ring < ring_divider:
		r = radius_increment * ring + radius
	else:
		r = ring_divider*radius_increment + radius + (ring-ring_divider)*radius_increment_large
	for i in range(spheres):
		var theta = ((PI*2) / spheres)
		var angle = (theta * i)
		spawn_sphere(Vector3(r * cos(angle),ring_height_distance*ring, r * sin(angle))+displacement, size+size_per_ring*ring, parent)


func _ready():
	for i in range(rings):
		var d = Vector3(0,0,0)
		spawn_ring(i, d)

func v3(x):
	return Vector3(x, x, x)

func flip_direction(property_current, property_start, property_end):
	if property_end > property_start:
		if property_current > property_end:
			return true
	else:
		if property_current < property_end:
			return true

func swap(parent, propA, propB):
	var tmp = parent.get(propA)
	parent.set(propA, parent.get(propB))
	parent.set(propB, tmp)

func _process(delta):
	self.rotate_y(delta * rotation_speed)
	for ring in ring_parents:
		ring.ref.rotate_y(delta * ring.rotation_speed)
		ring.ref.position.x = ring.ref.position.x + (ring.hd_end-ring.hd_start)/ring.hd_duration*delta
		if flip_direction(ring.ref.position.x, ring.hd_start, ring.hd_end):
			swap(ring, 'hd_start', 'hd_end')
	for ball in the_balls:
		ball.ref.scale = v3(ball.ref.scale.x + (ball.end_scale-ball.start_scale)/ball.scale_duration*delta)
		if flip_direction(ball.ref.scale.x, ball.start_scale, ball.end_scale):
			swap(ball, 'start_scale', 'end_scale')
