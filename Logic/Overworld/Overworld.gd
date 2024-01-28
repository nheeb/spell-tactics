extends Node3D

var player_position: Vector2i = Vector2i(0, 0)

@onready var nodes: LevelNodes = $LevelNodes
@onready var player_marker: Node3D = $Player
@onready var camera: Camera3D = $Camera3D

func _ready():
	player_marker.global_position = nodes.node_instance_sets[player_position.x][player_position.y].global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_click(event.position)

func _click(position: Vector2):
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * 999
	var space = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false
	var raycast_result = space.intersect_ray(ray_query)
	if raycast_result.has('collider'):
		var collider = raycast_result['collider']
		var node = collider
		if node is LevelNode:
			_click_node (node)

func _click_node(node: LevelNode):
	var location = node.location
	if not location.x == player_position.x + 1:
		return
	get_tree().change_scene_to_file("res://Logic/Main.tscn")
