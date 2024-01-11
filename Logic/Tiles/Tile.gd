class_name Tile extends Node3D

# Should the tile know its indices? Should the tile know its neighbours?
# leaning towards no..


func _on_area_3d_mouse_entered() -> void:
	$Edges.visible = true
	
func _on_area_3d_mouse_exited() -> void:
	$Edges.visible = false
