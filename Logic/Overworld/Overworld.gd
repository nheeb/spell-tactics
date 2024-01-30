class_name Overworld extends Node3D

var random_seed: int = 0
var map: OverworldMap
var player_position: Vector2i = Vector2i(0, 0)
var stage: int = 0

@onready var nodes: LevelNodes = $LevelNodes
@onready var player_marker: Node3D = $Player
@onready var camera: Camera3D = $Camera3D

func _ready():
	SaveFile.delete()
	if SaveFile.exists():
		load_save()
	else:
		map = OverworldMap.new()
		map.generate_prototype_layout()
	nodes.initialise(map)
	nodes.highlight_active_layer(player_position.x+1)
	player_marker.global_position = nodes.node_instance_sets[player_position.x][player_position.y].global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_click(event.position)

func _click(_position: Vector2):
	var from = camera.project_ray_origin(_position)
	var to = from + camera.project_ray_normal(_position) * 999
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
			node.click(self)

func move_to(_position: Vector2i):
	player_position = _position
	player_marker.global_position = nodes.node_instance_sets[player_position.x][player_position.y].global_position
	
func load_save():
	var save_state = SaveFile.load_from_disk()
	deserialize(save_state)

func deserialize(state: OverworldState):
	random_seed = state.random_seed
	stage = state.stage
	player_position = state.player_position
	map = state.map

func save():
	SaveFile.save_to_disk(serialize())

func serialize() -> OverworldState:
	var state = OverworldState.new()
	state.random_seed = random_seed
	state.stage = stage
	state.player_position = player_position
	state.map = map
	return state

func set_active() -> void:
	camera.make_current()
