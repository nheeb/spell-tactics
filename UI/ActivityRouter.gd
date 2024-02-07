extends Control

@export var activity_to_view_map: Array[ActivityRouterEntry] = []

var views: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	ActivityManager.activity_popped.connect(_on_activity_popped)
	ActivityManager.activity_pushed.connect(_on_activity_pushed)

func _on_activity_popped(activity: Activity):
	var pos = len(views)-1
	var view = views[pos]
	views.remove_at(pos)
	remove_child(view)
	_show_top()

func _on_activity_pushed(activity: Activity):
	var script = activity.get_script().get_path()
	for entry in activity_to_view_map:
		if entry.activity_script_path == script:
			var view = entry.packed_scene.instantiate()
			if view.has_method("set_activity"):
				view.set_activity(activity)
			views.append(view)
			add_child(view)
			_hide_all_but_top()
			_show_top()
			return

	printerr('unsupported activity script: %s' % script)

func _hide_all_but_top():
	for i in range(len(views)-1):
		views[i].hide()
	
func _show_top():
	views[len(views)-1].show()
