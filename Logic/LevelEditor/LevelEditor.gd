class_name EditorUI extends Control

@export var world: World = null
@onready var selection_ui = $%Entities

var all_levels_paths: Array[String] = []
var current_level_path = Game.LEVEL_PATH_DEFAULT

var tool_terrain_placer = TerrainPlace.new()
var tool_raise = Raise.new()
var tool_lower = Lower.new()
var tool_placer = Placer.new()
var tool_erase = Erase.new()
var tool_select_entity = SelectEntityTool.new()



var placement_active: EntityType = null
var tool_active = null:
	set(t):
		tool_active = t
var ent_active: EntityType = null

@onready var tile_hover_blocker: Block.Blocker = Preloaded.mouse_block.register_blocker()
@onready var zoom_blocker: Block.Blocker = GameCamera.zoom_block.register_blocker()
@onready var translate_blocker: Block.Blocker = GameCamera.translate_block.register_blocker()

## LevelEditor should load with a combat state
func _ready() -> void:
	Game.LEVEL_EDITOR = true
	if world == null:
		if has_node("%World"):
			world = get_node("%World")
		else:
			push_error("LevelEditor expecting either an exported World node or World accessible by get_node(\"%World\")")
	
	load_level(current_level_path)
	Game.settings.changed_render_resolution.connect(on_changed_render_resolution)
	Events.tile_clicked.connect(tile_clicked)
	get_window().title = "SpellTactics Level Editor ❤️"
	all_levels_paths = find_all_levels()

	for level_path in all_levels_paths:
		var filename = level_path.split("/")[-1].split(".tres")[0]
		if "event" in filename:
			continue
		$%LevelSelection.add_item(filename)
		var idx = $%LevelSelection.item_count - 1
		$%LevelSelection.set_item_metadata(idx, level_path)
		
		if level_path == current_level_path:
			$%LevelSelection.selected = idx
			
	# initialize tools
	tool_select_entity.inspector = %Inspector


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		#save_current_level()
		get_tree().quit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		%World.relative_motion = event.relative
	
func on_changed_render_resolution(res: Vector2i):
	%Viewport3D.size = res


const LEVEL_ROOT = "res://Content/Levels/"
func find_all_levels():
	var levels: Array[String] = []
	_find_tres_files_recursive(LEVEL_ROOT, levels)
	return levels

func _find_tres_files_recursive(path: String, result: Array):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_find_tres_files_recursive(path.path_join(file_name), result)
			elif file_name.ends_with(".tres"):
				result.append(path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()


## FIXME this is the dirty fix to level editor killing all events
var global_event_schedules: Array[CombatEventSchedule]
var global_enemy_events: Array[EnemyEventPlan]

func load_level(level_path: String):
	var combat_state = ResourceLoader.load(level_path) as CombatState
	if global_event_schedules.is_empty():
		global_event_schedules = combat_state.event_schedules
	if global_enemy_events.is_empty():
		global_enemy_events = combat_state.enemy_event_queue
	world._reset_combat()
	await world.load_combat_from_state(combat_state, false)
	current_level_path = level_path
	$%LevelSize.value = world.level.get_grid_size()
	
func save_current_level():
	var combat_state := world.combat.serialize()
	# FIXME We copy the events from the old state because serialization is broken rn
	combat_state.event_schedules = global_event_schedules
	combat_state.enemy_event_queue = global_enemy_events
	ResourceSaver.save(combat_state, current_level_path)

func _on_terrain_place_pressed() -> void:
	tool_active = tool_terrain_placer
	selection_ui.set_mode(SelectionUI.Mode.Terrain)

func _on_raise_pressed():
	tool_active = tool_raise	
	selection_ui.set_mode(SelectionUI.Mode.Terrain)

func _on_lower_pressed():
	tool_active = tool_lower
	selection_ui.set_mode(SelectionUI.Mode.None)

func _on_place_pressed():
	tool_active = tool_placer
	selection_ui.set_mode(SelectionUI.Mode.Entities)
	
func _on_select_pressed() -> void:
	tool_active = tool_select_entity

func _on_erase_pressed():
	tool_active = tool_erase
	selection_ui.set_mode(SelectionUI.Mode.None)
	
func tile_clicked(tile):
	if tool_active != null:
		tool_active._apply(world.level, tile, self)
		
func mouse_entered_editor_ui():
	tile_hover_blocker.block()
	zoom_blocker.block()
	
func mouse_exited_editor_ui():
	tile_hover_blocker.unblock()
	zoom_blocker.unblock()

func _on_level_selection_item_selected(idx: int) -> void:
	var new_lvl_path = $%LevelSelection.get_item_metadata(idx)
	#save_current_level()
	load_level(new_lvl_path)

func _on_level_size_value_changed(value: float) -> void:
	value = int(value)
	var current_size = world.level.get_grid_size()
	
	if value > current_size:
		world.level.expand_level_boundaries()
	elif value < current_size:
		var res: bool = world.level.shrink_level_boundaries()
		if not res:  # couldn't shrink
			# Reset the spin box value to the current grid size
			$%LevelSize.set_value_no_signal(current_size)
	
	$%LevelSize.set_value_no_signal(world.level.get_grid_size())


func _on_save_button_pressed() -> void:
	save_current_level()
	%SavedLabel.visible = true
	await get_tree().create_timer(2.5).timeout
	%SavedLabel.visible = false
