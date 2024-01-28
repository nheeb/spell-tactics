class_name LevelNodeData extends Resource

@export var type: LevelNode.NodeType = LevelNode.NodeType.Empty
@export var from: Array[int] = []

static func create(_type: LevelNode.NodeType) -> LevelNodeData:
	var data : LevelNodeData = LevelNodeData.new()
	data.type = _type
	data.from = [0, 1, 2, 3] # test
	return data

func add_from(previous_position: int):
	if not from.has(previous_position):
		from.append(previous_position)
