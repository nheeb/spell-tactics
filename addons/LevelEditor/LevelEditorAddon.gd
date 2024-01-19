@tool
extends EditorPlugin

var _editor_ui: EditorUI = null

var _editor_cameras: Array[Camera3D] = []
var _editor: GridLevelEditor = null

func _enter_tree():
	add_custom_type("GridLevelEditor", "Node", preload("GridLevelEditor.gd"), preload("hexagon.png"))
	_editor_ui = preload("res://addons/LevelEditor/UI/EditorUI.tscn").instantiate()
	EditorInterface.get_editor_main_screen().add_child(_editor_ui, true)
	_find_cameras(EditorInterface.get_editor_main_screen())
	_make_visible(false)

func _exit_tree():
	remove_custom_type("Editor")
	if _editor_ui:
		_editor_ui.queue_free()

func _handles(object: Object) -> bool:
	if object is GridLevelEditor:
		_editor = object
		return true
	_editor = null
	return false

func _make_visible(visible):
	if _editor_ui:
		_editor_ui.visible = visible
	pass

func _apply_changes():
	if _editor:
		_editor.save_changes()
	
func _forward_3d_gui_input(camera, event):
	if event is InputEventMouse:
		if event.button_mask != MOUSE_BUTTON_MASK_LEFT:
			return EditorPlugin.AFTER_GUI_INPUT_PASS
		else:
			_on_editor_click(event.position, event is InputEventMouseMotion)
	return EditorPlugin.AFTER_GUI_INPUT_STOP

func _on_editor_click(mouse_pos: Vector2i, drag: bool):
	var camera = _editor_cameras[0]
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 999
	var space = camera.get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = false
	var raycast_result = space.intersect_ray(ray_query)
	if raycast_result.has('collider'):
		var collider = raycast_result['collider']
		var tile = collider.get_parent()
		if tile is Tile:
			if not drag:
				_editor_ui.tool_active._apply(_editor, tile, _editor_ui.placement_active)
			else:
				_editor_ui.tool_active._drag(_editor, tile, _editor_ui.placement_active)

func _find_cameras(n : Node):
	if n is Camera3D:
		_editor_cameras.append(n)
		return
	
	for c in n.get_children():
		_find_cameras(c)
