class_name LevelNodeData extends Resource

@export var type: LevelNode.NodeType = LevelNode.NodeType.Empty
@export var from: Array[int] = []
@export var level_path: String = ""

static func create(_type: LevelNode.NodeType) -> LevelNodeData:
	var data : LevelNodeData = LevelNodeData.new()
	data.type = _type
	data.from = [0, 1, 2, 3] # test
	if _type == LevelNode.NodeType.Battle:
		data.level_path = "res://Levels/Area1/rivers.tres"
	return data

func add_from(previous_position: int):
	if not from.has(previous_position):
		from.append(previous_position)
