class_name LevelNode extends Area3D

enum NodeType { 
	Empty, 
	Battle,
	Event,
	Boss
}

@export var data: NodeData

func _ready():
	if data.type == NodeType.Event:
		add_child(preload("res://Logic/Overworld/Visuals/EventNodeVisual.tscn").instantiate())
	elif data.type == NodeType.Boss:
		add_child(preload("res://Logic/Overworld/Visuals/BossNodeVisual.tscn").instantiate())
	else:
		add_child(preload("res://Logic/Overworld/Visuals/GenericNodeVisual.tscn").instantiate())

func _process(delta):
	pass
