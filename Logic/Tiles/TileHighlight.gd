class_name Highlight extends Node3D

enum Type {
	Hover,
	Movement,
	Combat,
	Energy
}


@onready var material: StandardMaterial3D = $Edges/Edge1.mesh.material
var current_highlights: Array[Type] = []


const type_to_color := {
	Type.Movement: Color.WEB_GRAY,
	Type.Hover: Color.LIGHT_BLUE,
	Type.Combat: Color.LIGHT_CORAL,
	Type.Energy: Color.LIME
}


func enable_highlight(type: Type):
	# will be custom for each type. for now just change color
	if not type in current_highlights:
		material.albedo_color = type_to_color[type]
		current_highlights.append(type)
		$Edges.visible = true
	
func disable_highlight(type: Type):
	if type in current_highlights:
		current_highlights.erase(type)
	if current_highlights.is_empty():
		$Edges.visible = false
