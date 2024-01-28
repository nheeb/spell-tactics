class_name OverworldMap extends Resource

@export var node_sets : Array[Array] = []

func generate_prototype_layout():
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Empty)
	])
	for i in range(1):
		node_sets.append([
			NodeData.new(LevelNode.NodeType.Battle),
			NodeData.new(LevelNode.NodeType.Battle),
			NodeData.new(LevelNode.NodeType.Battle),
		])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Event),
		NodeData.new(LevelNode.NodeType.Event),
	])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Event),
		NodeData.new(LevelNode.NodeType.Event),
	])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Battle),
		NodeData.new(LevelNode.NodeType.Battle),
	])
	node_sets.append([
		NodeData.new(LevelNode.NodeType.Boss)
	])
