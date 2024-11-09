class_name Tile3D extends Node3D

var tile: Tile

@onready var level: Level = get_parent() as Level
var combat: Combat:
	get:
		return level.combat
@onready var highlight: Highlight = $Highlight
	
func _on_area_3d_mouse_entered() -> void:
	set_highlight(Highlight.Type.Hover, true)
	
func _on_area_3d_mouse_exited() -> void:
	set_highlight(Highlight.Type.Hover, false)

func set_highlight(type: Highlight.Type, active: bool):
	if active:
		$Highlight.enable_highlight(type)
	else:
		$Highlight.disable_highlight(type)

func _on_hover_timer_timeout() -> void:
	tile.hovering = true
	tile.combat.action_stack.process_player_action(PAHoverTileLong.new(tile, true))

func _to_string() -> String:
	return name
