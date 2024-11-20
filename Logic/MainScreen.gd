extends CanvasLayer

var activity: CombatActivity

func set_activity(_activity: CombatActivity):
	self.activity = _activity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%World.relative_motion = event.relative

func _ready():
	# set content size to 0 in windowed mode, so the render resolution stays
	# identical to the window size on resize
	#if get_window().mode == Window.MODE_WINDOWED:
		#get_window().content_scale_size = Vector2(0, 0)
	if get_tree().current_scene == self:
		activity = CombatActivity.new("res://Levels/Area1/clearing.tres")
	if activity:
		if activity.combat_state:
			await %World.load_combat_from_state(activity.combat_state)
		elif activity.level_path:
			await %World.load_combat_from_path(activity.level_path)
		else:
			push_error("Invalid Combat Activity")
		activity.combat = %World.get_node("Combat")
	
	# connect resized event
	#get_tree().root.connect("size_changed", _on_window_resized)
	$DebugLabel.text = "3D size: " + str(%Viewport3D.size) + ", Root size: " + str(get_tree().root.size)
	
	Game.settings.changed_render_resolution.connect(on_changed_render_resolution)


func on_changed_render_resolution(res: Vector2i):
	%Viewport3D.size = res
