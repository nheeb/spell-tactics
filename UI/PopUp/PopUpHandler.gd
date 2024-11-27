## The PopupHandler's main job is to update all screen space popup's positions each frame.
## The Popups themselves are owned by each tile
class_name PopupHandler extends Control

@export var viewport: Viewport
@export var drainable_root: Control
@export var popup_root: Control

@onready var hover_popup: HoverPopup

const HOVER_POPUP = preload("res://UI/PopUp/HoverPopup.tscn")
#const ENERGY_POPUP = preload ("res://UI/PopUp/EnergyPopup.tscn")  # remove this
var current_tile: Tile
var screen_pos: Vector2 # target from unprojecting the camera
var prev_screen_pos: Vector2
var active_entries: Dictionary = {} # Tile -> DrainableEntry
var active_hovers: Dictionary = {}  # Tile -> DrainableEntry
var combat: Combat


func _ready() -> void:
	Events.tile_hovered_long.connect(show_tile_popup)
	Events.tile_unhovered_long.connect(hide_tile_popup)
	PAHoverTile.on_drainable_tile_hovered.connect(on_drainable_tile_hovered)
	PAHoverTile.on_drainable_tile_unhovered.connect(on_drainable_tile_unhovered)
	Game.energy_overlay_changed.connect(energy_overlay_changed)
	hover_popup = HOVER_POPUP.instantiate()

func energy_overlay_changed(overlay_active: bool):
	if overlay_active:
		show_drainable_overlay()
	else:
		hide_drainable_overlay()

func _exit_tree():
	Events.tile_hovered_long.disconnect(show_tile_popup)
	Events.tile_unhovered_long.disconnect(hide_tile_popup)
	reset()

func show_tile_popup(tile: Tile):
	# don't show popup if the tile only has drainable entities (so nothing special to show e.g. enemies)
	# AND we are already showing the drainable overlay for this tile
	if (not tile.has_enemy()) and tile in active_hovers:
		return
	current_tile = tile
	# can use Camera3D.is_position_behind() to check, but should not be relevant here for now
	screen_pos = viewport.get_camera_3d().unproject_position(tile.global_position)
	
	if not hover_popup.is_inside_tree():
		popup_root.add_child(hover_popup)
	else:
		push_error("trying to show 2nd popup while 1st still showing")
	hover_popup.position = screen_pos
	hover_popup.show_tile(tile)

func hide_tile_popup(tile: Tile):
	if hover_popup.is_inside_tree():
		popup_root.remove_child(hover_popup)
	else:
		# this happens if we did NOT show a popup on long hover for any reason
		# (early return in show_tile_popup)
		pass
	current_tile = null
	hover_popup.hide_popup()

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
		push_error("can't show overlay without combat reference")
		return
	if not active_entries.is_empty():
		for key in active_entries.keys():
			active_entries[key].queue_free()
		active_entries.clear()

	# recalculate every time for now..
	# TODO put this into beginning of combat!!!
	# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	setup_popups()
	
	# TODO remove :)

var tile_hovered: Tile
func on_drainable_tile_hovered(tile: Tile):
	# don't show extra if energyoverlay is active
	if Game.ENERGY_OVERLAY:
		return
	var entry: EnergyPopup
	#print("show ", tile)
	if not tile in active_hovers:  # active_hovers
		#entry = place_drainable_entry(tile)
		push_warning("drainable tile hovered not implemented yet")
		active_hovers[tile] = entry
	else:
		entry = active_hovers[tile]
	
	if entry != null:
		entry.show()
	tile_hovered = tile

func on_drainable_tile_unhovered(tile: Tile):
	if not tile in active_hovers:
		return
		
	#if drainable_hovered != null: # is this needed??
		#active_entries[drainable_hovered].hide()
		#drainable_hovered = null

	var entry: EnergyPopup = active_hovers[tile]
	#print("hide ", tile)
	if entry != null:
		entry.hide()
	
func hide_drainable_overlay():
	drainable_root.hide()
	for drainable in drainable_root.get_children():
		if tile_hovered in active_entries and drainable == active_entries[tile_hovered]:
			continue
		else:
			drainable.visible = false


func setup_popups():
	# TODO new functionality: go over all tiles and add the popup to the popup_root
	pass


#func setup_active_entries() -> Dictionary:  # Tile -> DrainableEntry
	#var drainable_ents: Dictionary = combat.level.get_drainable_entities() # Tile -> Array[Entity]
	#var entries: Dictionary = {}
	## iterate over each tile
	#for tile in drainable_ents.keys():
		#tile = tile as Tile
		## var energy = EnergyStack.new()
		## merge all drainable energies
		## for ent in drainable_ents[tile]:
			## energy.stack.append_array(ent.energy.stack)
		#
		## create a DrainableEntry on top of the tile in screen space
		#var entry = place_drainable_entry(tile)
		#entries[tile] = entry
#
	#return entries


## DEPRECATED
#func place_drainable_entry(tile: Tile) -> EnergyPopup:
	#var energy = tile.get_drainable_energy()
	##var entry = ENER.instantiate()
	#entry.connected_tile = tile
	#entry.name = "DrainableEntry_%d_%d" % [tile.r, tile.q]
	#drainable_root.add_child(entry)
	#entry.owner = drainable_root
	#entry.show_energy(energy)
	#var _screen_pos = viewport.get_camera_3d().unproject_position(entry.connected_tile.global_position)
	## scale screen pos
	##_screen_pos = Utility.inv_scale_screen_pos(_screen_pos)
	#entry.position = (_screen_pos - entry.size / 2).round()
	#return entry


	
func update_active_entries(entries: Array[EnergyPopup]):  # not called atm :((
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

func update_popup_position(popup: EnergyPopup):
	var cam = viewport.get_camera_3d()
	#if entry.visible:
	popup.visible = not cam.is_position_behind(popup.connected_tile.global_position)
	var _screen_pos = viewport.get_camera_3d().unproject_position(popup.connected_tile.global_position)
	#_screen_pos = Utility.inv_scale_screen_pos(_screen_pos).round()
	popup.position = _screen_pos - popup.size / 2 # unfortunately necessary..

const threshold: float = .1
func _process(delta: float) -> void:
	if current_tile != null:
		prev_screen_pos = screen_pos
		screen_pos = viewport.get_camera_3d().unproject_position(current_tile.global_position)

		# doesn't work properly, might remove this if clause (was meant to reduce stutter)
		if prev_screen_pos.distance_to(screen_pos) > threshold:
			hover_popup.position = screen_pos
	
	# once we have large levels in theory we could some kind of frustum culling...
	for popup in EnergyPopup.active_popups:
		#if tile == null or entry == null:
			#push_error("unexpected key", tile, "in active entries. (expecting a Tile)")
			#return
		
		update_popup_position(popup)

	# should not be needed anymore:
	#for tile in active_hovers:
		#update_popup_position(active_hovers[tile])

func _on_world_combat_changed(_combat: Combat):
	self.combat = _combat
	#combat.get_phase_node(Combat.RoundPhase.Spell).process_start.connect(show_surrounding_drainable_entries)
