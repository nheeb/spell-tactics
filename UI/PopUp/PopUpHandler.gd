class_name PopUpHandler extends Control

@export var viewport: Viewport
@export var drainable_root: Control
@export var popup_root: Control

@onready var popup

const POPUP = preload ("res://UI/PopUp.tscn")
const DRAINABLE_ENTRY = preload ("res://UI/PopUp/DrainableEntry.tscn")
var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2
var active_entries: Dictionary = {}
var active_hovers: Dictionary = {}  # don't ask..
var combat: Combat
var is_showing_energy_overlay: bool = false

func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)
	PAHoverTile.on_drainable_tile_hovered.connect(on_drainable_tile_hovered)
	PAHoverTile.on_drainable_tile_unhovered.connect(on_drainable_tile_unhovered)
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
		popup_root.add_child(popup)
	else:
		printerr("trying to show 2nd popup while 1st still showing")
	popup.position = screen_pos
	popup.show_tile(tile)

func hide_tile_popup(tile: Tile):
	if popup.is_inside_tree():
		popup_root.remove_child(popup)
	else:
		printerr("weird not inside tree")
	current_tile = null
	popup.hide_popup()

## should be called on level changed!
func reset():
	active_entries = {}
	set_process(false)
	pass

func start():
	set_process(true)

## Reference to the list of control popup entries. 
func show_drainable_overlay():
	drainable_root.show()
	if combat == null:
		printerr("can't show overlay without combat reference")
		return
	if not active_entries.is_empty():
		for key in active_entries.keys():
			active_entries[key].queue_free()
		active_entries.clear()

	# recalculate every time for now..
	active_entries = setup_active_entries()
	is_showing_energy_overlay = true

var tile_hovered: Tile
func on_drainable_tile_hovered(tile: Tile):
	var entry: DrainableEntry
	#print("show ", tile)
	if not tile in active_hovers:  # active_hovers
		entry = place_drainable_entry(tile)
		active_hovers[tile] = entry
	else:
		entry = active_hovers[tile]
	
	entry.show()
	tile_hovered = tile

func on_drainable_tile_unhovered(tile: Tile):
	if not tile in active_hovers:
		return
		
	#if drainable_hovered != null: # is this needed??
		#active_entries[drainable_hovered].hide()
		#drainable_hovered = null

	var entry: DrainableEntry = active_hovers[tile]
	#print("hide ", tile)
	entry.hide()
	
func hide_drainable_overlay():
	drainable_root.hide()
	for drainable in drainable_root.get_children():
		if tile_hovered in active_entries and drainable == active_entries[tile_hovered]:
			continue
		else:
			drainable.visible = false
	is_showing_energy_overlay = true
	#for entry in active_entries:
		#entry.hide()

## This should ideally be called on loading the level, so the PopUps don't have to
## get instantiated on the fly. It instantiates all Overlay Control nodes.
## For updating, call update_active_entries() instead
func setup_active_entries() -> Dictionary:  # Tile -> DrainableEntry
	var drainable_ents: Dictionary = combat.level.get_drainable_entities() # Tile -> Array[Entity]
	var entries: Dictionary = {}
	# iterate over each tile
	for tile in drainable_ents.keys():
		tile = tile as Tile
		# var energy = EnergyStack.new()
		# merge all drainable energies
		# for ent in drainable_ents[tile]:
			# energy.stack.append_array(ent.energy.stack)
		
		# create a DrainableEntry on top of the tile in screen space
		var entry = place_drainable_entry(tile)
		entries[tile] = entry

	return entries

func place_drainable_entry(tile: Tile) -> DrainableEntry:
	var energy = tile.get_drainable_energy()
	var entry = DRAINABLE_ENTRY.instantiate()
	entry.connected_tile = tile
	entry.name = "DrainableEntry_%d_%d" % [tile.r, tile.q]
	drainable_root.add_child(entry)
	entry.owner = drainable_root
	entry.show_energy(energy)
	var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
	# scale screen pos
	#_screen_pos = Utility.inv_scale_screen_pos(_screen_pos)
	entry.position = (_screen_pos - entry.size / 2).round()
	return entry


	
func update_active_entries(entries: Array[DrainableEntry]):  # not called atm :((
	for entry in entries:
		var tile = entry.connected_tile
		var energy: EnergyStack = tile.get_drainable_energy()
		if not energy.is_empty():
			entry.show_energy(energy)
			entry.show()
		else:
			entry.reset()
			
func show_surrounding_drainable_entries():  # broken?!?
	var _position: Tile = combat.player.current_tile
	var neighbours: Array[Tile] = combat.level.get_all_tiles_in_distance_of_tile(_position, 1)
	
	for neighbour in neighbours:
		if neighbour in active_entries:
			active_entries[neighbour].show()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("show_drain_overlay") and get_window().has_focus():
		show_drainable_overlay()
		
	if Input.is_action_just_released("show_drain_overlay") or (not get_window().has_focus()):
		hide_drainable_overlay()

func update_entry_position(entry: DrainableEntry):
	var cam = viewport.get_camera_3d()
	if entry.visible:
		entry.visible = not cam.is_position_behind(entry.connected_tile.global_position)
	var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
	#_screen_pos = Utility.inv_scale_screen_pos(_screen_pos).round()
	entry.position = _screen_pos - entry.size / 2 # unfortunately necessary..	

const threshold: float = .1
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)

		# doesn't work properly, might remove this if clause (was meant to reduce stutter)
		if prev_screen_pos.distance_to(screen_pos) > threshold:
			popup.position = screen_pos

	for tile in active_entries:
		var entry: DrainableEntry = active_entries[tile]
		if tile == null or entry == null:
			printerr("unexpected key", tile, "in active entries. (expecting a Tile)")
			return
		
		update_entry_position(entry)
		
	for tile in active_hovers:
		update_entry_position(active_hovers[tile])

func _on_world_combat_changed(_combat: Combat):
	self.combat = _combat
	#combat.get_phase_node(Combat.RoundPhase.Spell).process_start.connect(show_surrounding_drainable_entries)
