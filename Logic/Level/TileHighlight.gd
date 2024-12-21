class_name Highlight extends Node3D

enum Type {  # TODO cleanup, which of these do we still use?
	Hover,
	HoverTarget,
	MovementTarget,
	Combat,
	Energy,
	LowSpellEnergy,
	HighSpellEnergy,
	PossibleTarget,
	SelectedTarget,
	PlayerFocus,
	HoverAction,
	HoverInteract,
}

@onready var typeToMesh: Dictionary = {
	Type.Hover: $HoverHexQuad,
	Type.HoverTarget: $HoverTargetHexQuad,
	Type.HoverAction: $HoverAction,
	Type.HoverInteract: $HoverInteract,
	Type.MovementTarget: $MovementTarget,
	Type.Combat: $CombatHexQuad,
	Type.LowSpellEnergy: $LowSpellEnergyHexQuad,
	Type.HighSpellEnergy: $HighSpellEnergyHexQuad,
	Type.PossibleTarget: $PossibleTargetQuad,
	Type.SelectedTarget: $SelectedTargetQuad
}

## Highlights being preferred over others
const superseding_types: Dictionary = {
	Type.HoverAction: [Type.Hover],
	# this means when both of these are active, only show HoverAction
	Type.HoverInteract: [Type.HoverAction, Type.Hover],
}

var current_highlights: Array[Type] = []

func enable_highlight(type: Type):
	if not type in current_highlights:
		current_highlights.append(type)
		
		if type in typeToMesh:
			typeToMesh[type].visible = true
		else:
			push_warning("unhandled highlight type " + Type.keys()[type])
			
		if type in superseding_types:
			for superseded in superseding_types[type]:
				typeToMesh[superseded].visible = false

func disable_highlight(type: Type):
	if type in current_highlights:
		current_highlights.erase(type)
	else:  # wasn't even active, so no need to update the materials
		return
		
	if type in typeToMesh:
		typeToMesh[type].visible = false
	else:
		push_warning("unhandled highlight type " + Type.keys()[type])
		
	if type in superseding_types:
		for superseded in superseding_types[type]:
			# check if this one is still active, then make it visible again
			if superseded in current_highlights:
				typeToMesh[superseded].visible = true

## Shows and sets the progress of the drain-hex-bar to a value between 0.0 and 1.0 .
func set_border_progress(p := 0.0) -> void:
	$BorderProgressHexQuad.visible = p != 0.0
	$BorderProgressHexQuad.get_surface_override_material(0).set("shader_parameter/progress", p)

func set_border_progress_color(color: Color):
	$BorderProgressHexQuad.get_surface_override_material(0).set("shader_parameter/albedo", color)

func set_border_progress_width(width: float = 0.07):
	$BorderProgressHexQuad.get_surface_override_material(0).set("shader_parameter/width", width)
