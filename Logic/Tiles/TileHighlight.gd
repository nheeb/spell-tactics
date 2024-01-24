class_name Highlight extends Node3D

enum Type {
	Hover,
	HoverTarget,
	Movement,
	Combat,
	Energy
}

var current_highlights: Array[Type] = []


const type_to_color := {
	Type.Movement: Color.WEB_GRAY,
	Type.Hover: Color.LIGHT_BLUE,
	Type.HoverTarget: Color.LIGHT_CORAL,
	Type.Energy: Color.LIME,
}

var highlight_materials = {}

var current_material: StandardMaterial3D:
	set(mat):
		for edge in $Edges.get_children():
			edge = edge as MeshInstance3D
			edge.material_override = mat
		current_material = mat

func _ready() -> void:
	var material: StandardMaterial3D = $Edges/Edge1.mesh.material.duplicate()
	for type in type_to_color.keys():
		var highlight_mat: StandardMaterial3D = material.duplicate()
		highlight_mat.albedo_color = type_to_color[type]
		highlight_materials[type] = highlight_mat


func enable_highlight(type: Type):
	if type == Type.Hover and not type in current_highlights:
		current_highlights.append(type)
		$HoverHexQuad.visible = true
	if type == Type.HoverTarget and not type in current_highlights:
		current_highlights.append(type)
		$HoverTargetHexQuad.visible = true
	if type == Type.Combat and not type in current_highlights:
		current_highlights.append(type)
		$CombatHexQuad.visible = true
	# will be custom for each type. for now just change color
	if not type in current_highlights:
		current_material = highlight_materials[type]
		current_highlights.append(type)
		$Edges.visible = true
	
func disable_highlight(type: Type):
	if type in current_highlights:
		current_highlights.erase(type)
	
	if type == Type.Hover:
		$HoverHexQuad.visible = false
		
	if type == Type.HoverTarget:
		$HoverTargetHexQuad.visible = false
		
	if type == Type.Combat:
		$CombatHexQuad.visible = false
	
	if current_highlights.is_empty():
		$Edges.visible = false
	else:
		current_material = highlight_materials[current_highlights[0]]
