class_name OverworldMap extends Resource

@export var node_sets : Array[Array] = []

func generate_prototype_layout():
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Empty)
	])
	for i in range(1):
		node_sets.append([
			LevelNodeData.create_battle(get_random_level()),
			LevelNodeData.create_battle(get_random_level()),
			LevelNodeData.create_battle(get_random_level()),
		])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Event),
		LevelNodeData.create(LevelNode.NodeType.Event),
	])
	node_sets.append([
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
	])
	node_sets.append([
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Event),
		LevelNodeData.create(LevelNode.NodeType.Event),
	])
	node_sets.append([
		LevelNodeData.create_battle(get_random_level()),
		LevelNodeData.create_battle(get_random_level()),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Boss)
	])

func get_random_level():
	return ['res://Levels/Area1/rivers.tres', 'res://Levels/Area1/clearing.tres'].pick_random()


# DEPRECATED AF
