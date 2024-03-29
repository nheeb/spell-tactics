extends Control

var transform_nodes : Array[Node2D] = []

func _ready() -> void:
	%IconTransforms.hide()
	for i in range(7):
		transform_nodes.append(%IconTransforms.get_node("Icon" + str(i+1)))

var icons: Array[TimelineEventIcon] = []

func build_timeline_from_log(log: LogUtility):
	pass


