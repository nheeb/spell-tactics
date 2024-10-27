class_name LevelNode extends Area3D

enum NodeType { 
	Empty, 
	Battle,
	Event,
	Boss
}

@export var data: LevelNodeData
@export var location: Vector2i

var _visual: Node3D

func _ready():
	var visual: Node3D
	if data.type == NodeType.Event:
		pass
		#visual = preload("res://Logic/Overworld/Visuals/EventNodeVisual.tscn").instantiate()
	elif data.type == NodeType.Boss:
		#visual = preload("res://Logic/Overworld/Visuals/BossNodeVisual.tscn").instantiate()
		pass
	else:
		#visual = preload("res://Logic/Overworld/Visuals/GenericNodeVisual.tscn").instantiate()
		pass
	_visual = visual
	add_child(visual)

func highlight_selectable(flag: bool):
	for child in _visual.get_children():
		if not child is MeshInstance3D:
			return
		if flag:
			#child.material_override = preload("res://Logic/Overworld/selectable.tres")
			pass
		else:
			child.material_override = null

func click(overworld: Overworld):
	if not location.x == overworld.player_position.x + 1:
		return
	overworld.move_to(location)
	overworld.save()
	ActivityManager.push(CombatActivity.new(data.level_path))
