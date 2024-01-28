class_name LevelNodes extends Node3D

@export var map: OverworldMap

const spacing_x = 2
const spacing_z = 2.5

var node_instance_sets = []

func _ready():
	map = OverworldMap.new()
	map.generate_prototype_layout()
	generate_nodes()
	generate_roads()
	highlight_active_layer(1)
	
func highlight_active_layer(index: int):
	for i in range(len(node_instance_sets)):
		for node_instance in node_instance_sets[i]:
			node_instance.highlight_selectable(index == i)

func get_terrain_height(pos: Vector3) -> Vector3:
	var parameters = PhysicsRayQueryParameters3D.create(pos + Vector3.UP * 10.0, pos + Vector3.DOWN * 10.0)
	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(parameters)
	if result.has("position"):
		return result["position"] as Vector3
	return pos

func generate_nodes():
	var pos_x = 0.0
	var i = 0
	for node_set in map.node_sets:
		var node_instance_set = []
		var pos_z = - 0.5 * (len(node_set)-1.0) * spacing_z
		var j = 0
		for node_data in node_set:
			var node = preload("res://Logic/Overworld/LevelNode.tscn").instantiate()
			node.data = node_data
			node.location = Vector2i(i, j)
			add_child(node)
			node.global_position = get_terrain_height(position + Vector3(pos_x, 0, pos_z))
			node_instance_set.append(node)
			pos_z += spacing_z
			j += 1
		pos_x += spacing_x
		node_instance_sets.append(node_instance_set)
		i += 1
	pass
	
func generate_roads():
	var i = 0
	for node_set in map.node_sets:
		if i != 0:
			var j = 0
			for node_data in node_set:
					generate_road(i, j)
					j += 1
		i += 1
		
func generate_road(i: int, j: int):
	var to_instance : LevelNode = node_instance_sets[i][j]
	var k = 0
	for node_data in map.node_sets[i-1]:
		var from : Array[int] = node_data.from
		if not from.has(j):
			continue
		
		var from_instance: LevelNode = node_instance_sets[i-1][k]
		var road_direction = (to_instance.global_position - from_instance.global_position).normalized()
		var length = (to_instance.global_position).distance_to(from_instance.global_position)
		var middle_position = (to_instance.global_position + from_instance.global_position) / 2.0
		var node = preload("res://Logic/Overworld/LevelPath.tscn").instantiate()
		add_child(node)
		node.global_position = get_terrain_height(middle_position) + Vector3.UP * 0.1
		node.look_at(node.global_position + road_direction)
		node.length = length
		k += 1
