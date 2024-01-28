class_name OverworldMap extends Resource

@export var node_sets : Array[Array] = []

func generate_prototype_layout():
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Empty)
	])
	for i in range(1):
		node_sets.append([
			LevelNodeData.create(LevelNode.NodeType.Battle),
			LevelNodeData.create(LevelNode.NodeType.Battle),
			LevelNodeData.create(LevelNode.NodeType.Battle),
		])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Event),
		LevelNodeData.create(LevelNode.NodeType.Event),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Event),
		LevelNodeData.create(LevelNode.NodeType.Event),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Battle),
		LevelNodeData.create(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		LevelNodeData.create(LevelNode.NodeType.Boss)
	])
