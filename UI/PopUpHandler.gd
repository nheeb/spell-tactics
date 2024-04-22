class_name PopUpHandler extends Control

@export var viewport: Viewport

@onready var popup

const POPUP = preload("res://UI/PopUp.tscn")
const DRAINABLE_ENTRY = preload("res://UI/PopUp/DrainableEntry.tscn")
var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2

var combat: Combat

func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)
	popup = POPUP.instantiate()

func _exit_tree():
	Events.tile_hovered_long.disconnect(show_tile_popup)
	Events.tile_unhovered_long.disconnect(hide_tile_popup)
	reset()

func show_tile_popup(tile: Tile):
	current_tile = tile
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now	
	screen_pos = viewport.get_camera_3d().unproject_position(tile.global_position)
	
	if not popup.is_inside_tree():
		add_child(popup)
	else:
		printerr("trying to show 2nd popup while 1st still showing")
	popup.position = screen_pos
	popup.show_tile(tile)

func hide_tile_popup(tile: Tile):
	if popup.is_inside_tree():
		remove_child(popup)
	else:
		printerr("weird not inside tree")
	current_tile = null
	popup.hide_popup()


## TODO call this on_level_changed !
func reset():
	active_entries = []
	set_process(false)
	pass


func start():
	set_process(true)


## Reference to the list of control popup entries. 
var active_entries: Array[DrainableEntry] = []
func show_drainable_overlay():
	$Drainables.show()
	if combat == null:
		printerr("can't show overlay without combat reference")
		return
	if not active_entries.is_empty():
		#update_active_entries(active_entries)
		for entry in active_entries:
			entry.queue_free()
		active_entries = setup_active_entries()
	else:
		active_entries = setup_active_entries()

	
func hide_drainable_overlay():
	#$Drainables.hide()
	for drainable in $Drainables.get_children():
		drainable.visible = false
	#for entry in active_entries:
		#entry.hide()
	

## This should ideally be called on loading the level, so the PopUps don't have to
## get instantiated on the fly. It instantiates all Overlay Control nodes.
## For updating, call update_active_entries() instead
func setup_active_entries() -> Array[DrainableEntry]:
	var drainable_ents: Dictionary = combat.level.get_drainable_entities()  # Tile -> Array[Entity]
	var entries: Array[DrainableEntry] = []
	# iterate over each tile
	for tile in drainable_ents.keys():
		tile = tile as Tile
		var energy = EnergyStack.new()
		# merge all drainable energies
		for ent in drainable_ents[tile]:
			energy.stack.append_array(ent.energy.stack)
		
		# create a DrainableEntry on top of the tile in screen space
		var entry = DRAINABLE_ENTRY.instantiate()
		entry.connected_tile = tile
		entry.name = "DrainableEntry_%d_%d" % [tile.r, tile.q]
		$Drainables.add_child(entry)
		entry.owner = self
		entry.show_energy(energy)
		var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
		entry.position = _screen_pos - entry.size/2
		entries.append(entry)
		
	return entries
	
func update_active_entries(entries: Array[DrainableEntry]):
	for entry in entries:
		var tile = entry.connected_tile
		var energy: EnergyStack = tile.get_drainable_energy()
		if not energy.is_empty():
			entry.show_energy(energy)
			entry.show()
		else:
			entry.reset()
			
func show_surrounding_drainable_entries():
	var _position: Tile = combat.player.current_tile
	var neighbours: Array[Tile] = combat.level.get_all_tiles_in_distance_of_tile(_position, 1)
	
	for neighbour in neighbours:
		if neighbour in active_entries:
			active_entries[neighbour].show()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_drain_overlay"):
		show_drainable_overlay()
	if Input.is_action_just_released("show_drain_overlay"):
		hide_drainable_overlay()

const threshold: float = .1
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)
		if prev_screen_pos.distance_to(screen_pos) > threshold:
			popup.position = screen_pos
	if not active_entries.is_empty():
		for entry in active_entries:
			var cam = viewport.get_camera_3d()
			if entry.visible:
				entry.visible = not cam.is_position_behind(entry.connected_tile.global_position)
			var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
			entry.position = _screen_pos - entry.size/2  # unfortunately necessary..
			
				
	#if current_tile != null:  # lerp towards camera to beat this stutter
		#var f = Engine.get_physics_interpolation_fraction()
		#var target_position: Vector2 = prev_screen_pos.lerp(screen_pos, f)
		#$PopUp.position = target_position

func _on_world_combat_changed(_combat: Combat):
	self.combat = _combat
	combat.get_phase_node(Combat.RoundPhase.Spell).process_start.connect(show_surrounding_drainable_entries)
