class_name MouseInput extends RayCast3D

# A reference to cards3d is needed here to see if the hover/click input is meant for this RayCast
# or the one in Cards3D (cards3d has priority, since it is "on top" visually)
var cards3d: Cards3D = null
# for checking current GamePhase
var combat: Combat

var disabled := false

func hover_tile(tile: Tile):
	if Preloaded.mouse_block.is_blocked():
		return
	PATileHoverUpdate.on_tile_hovered.emit(tile)  # alternativ: PATileHoverUpdate.new(), combat.trigger_action(PATileHoverUpdate.new(args))
	tile.get_node("HoverTimer").start()
	
func unhover_tile(tile: Tile):
	if tile.hovering:
		tile.hovering = false
	tile.get_node("HoverTimer").stop()
	Events.tile_unhovered.emit(tile)

static var currently_hovering: Tile = null
static var mouse_pos_3d: Vector3
func _process(delta: float) -> void:
	%MouseRaycast.force_raycast_update()
	var mouse_position := Utility.get_mouse_pos_absolute()
	var camera: Camera3D = %Camera3D
	var ray_origin := camera.project_ray_origin(mouse_position)
	var ray_direction := camera.project_ray_normal(Utility.scale_screen_pos(mouse_position))
	var intersect = Plane(Vector3.UP).intersects_ray(ray_origin, ray_direction)
	if intersect:
		mouse_pos_3d = intersect
	var end := ray_origin + ray_direction * camera.far
	self.target_position = to_local(end)
	
	# if something has been hit and hasn't been hit in Cards3D as well
	if is_colliding() and (cards3d == null or not cards3d.raycast_hit) and not disabled:
		var collider = get_collider()
		if collider is Area3D:
			if collider.is_in_group("tile_area"):
				var tile3d: Tile3D = collider.get_parent()
				var tile: Tile = tile3d.tile
				if currently_hovering != null and currently_hovering != tile:
					unhover_tile(currently_hovering)
				if tile != currently_hovering:
					hover_tile(tile)
				currently_hovering = tile
	else:
		if currently_hovering != null:
			unhover_tile(currently_hovering)
			currently_hovering = null
			
	if currently_hovering and Input.is_action_just_pressed("select") and not Preloaded.mouse_block.is_blocked():
		#var connections = Events.tile_clicked.get_connections()
		Events.tile_clicked.emit(currently_hovering)
	
	if currently_hovering and Input.is_action_just_released("select"):
		Events.tile_click_released.emit(currently_hovering)
	
	if currently_hovering and Input.is_action_just_pressed("deselect") and not Preloaded.mouse_block.is_blocked():
		Events.tile_rightclicked.emit(currently_hovering)
