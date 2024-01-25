class_name NodeData extends Resource

@export var type: LevelNode.NodeType = LevelNode.NodeType.Empty
@export var from: Array[int] = []

func _init(_type: LevelNode.NodeType):
	type = _type
	from = [0, 1, 2, 3] # test

func add_from(previous_position: int):
	if not from.has(previous_position):
		from.append(previous_position)
