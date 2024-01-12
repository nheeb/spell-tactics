class_name Tile extends Node3D

var entities: Array[Entity]

# Should the tile know its indices? Should the tile know its neighbours?
# leaning towards no..


func _on_area_3d_mouse_entered() -> void:
	$Edges.visible = true
	
func _on_area_3d_mouse_exited() -> void:
	$Edges.visible = false
	
func add_entity(entity: Entity):
	entities.append(entity)
	if entity.visual_entity != null:
		$Visuals.add_child(entity.visual_entity)
		entity.visual_entity.owner = self
