class_name PopUpHandler extends Control

@export var viewport: Viewport

@onready var popup

const POPUP = preload ("res://UI/PopUp.tscn")
const DRAINABLE_ENTRY = preload ("res://UI/PopUp/DrainableEntry.tscn")
var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2

# TODO fix it so that PopUps get centered onto the Tile again :)
#    the issue is when resizing. so in base size it looks fine but in full screen it's not centered

var combat: Combat

func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)
	PAHoverTile.on_drainable_tile_hovered.connect(on_drainable_tile_hovered)
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

## should be called on level changed!
func reset():
	active_entries = {}
	set_process(false)
	pass

func start():
	set_process(true)

## Reference to the list of control popup entries. 
var active_entries: Dictionary = {}
func show_drainable_overlay():
	$Drainables.show()
	if combat == null:
		printerr("can't show overlay without combat reference")
		return
	if not active_entries.is_empty():
		for key in active_entries.keys():
			active_entries[key].queue_free()
		active_entries.clear()

	# recalculate every time for now..
	active_entries = setup_active_entries()

var drainable_hovered: Tile
func on_drainable_tile_hovered(tile: Tile):
	show_tile_energies(tile)
	drainable_hovered

func on_drainable_tile_unhovered(tile: Tile):
	if not tile in active_entries:
		return

	var entry: DrainableEntry = active_entries[tile]
	entry.hide()
	
func hide_drainable_overlay():
	#$Drainables.hide()
	for drainable in $Drainables.get_children():
		drainable.visible = false
	#for entry in active_entries:
		#entry.hide()

func show_tile_energies(tile: Tile):
	var entry: DrainableEntry
	if not tile in active_entries:
		entry = place_drainable_entry(tile)
	else:
		entry = active_entries[tile]
	active_entries[tile] = entry
	entry.show()

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
	$Drainables.add_child(entry)
	entry.owner = self
	entry.show_energy(energy)
	var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
	# scale screen pos
	_screen_pos = Utility.inv_scale_screen_pos(_screen_pos)
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

const threshold: float = .1
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)
		screen_pos = Utility.inv_scale_screen_pos(screen_pos).round()
		if prev_screen_pos.distance_to(screen_pos) > threshold:
			popup.position = screen_pos
	if not active_entries.is_empty():
		for tile in active_entries:
			tile = tile as Tile
			var entry = active_entries[tile]
			if tile == null or entry == null:
				printerr("unexpected key", tile, "in active entries. (expecting a Tile)")
				return
			
			var cam = viewport.get_camera_3d()
			if entry.visible:
				entry.visible = not cam.is_position_behind(entry.connected_tile.global_position)
			var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
			_screen_pos = Utility.inv_scale_screen_pos(_screen_pos).round()
			entry.position = _screen_pos - entry.size / 2 # unfortunately necessary..
				
	#if current_tile != null:  # lerp towards camera to beat this stutter
		#var f = Engine.get_physics_interpolation_fraction()
		#var target_position: Vector2 = prev_screen_pos.lerp(screen_pos, f)
		#$PopUp.position = target_position

func _on_world_combat_changed(_combat: Combat):
	self.combat = _combat
	#combat.get_phase_node(Combat.RoundPhase.Spell).process_start.connect(show_surrounding_drainable_entries)
