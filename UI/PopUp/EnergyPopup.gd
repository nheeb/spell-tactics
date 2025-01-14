class_name EnergyPopup extends PanelContainer

## Each EnergyPopup is responsible for adding/removing itself from this list.
## Depending on whether it's currently showing. This is mainly used by the PopupHandler
## to update the screen space position each frame.
static var ACTIVE_POPUPS: Array[EnergyPopup] = []
@export var icon_size := 38

var tile: Tile = null
var combat: Combat

# TODO change all icon's min_size on window resized!
enum ActiveCause {  # not implemented yet - just an idea
	OVERLAY, DRAIN_HOVER, DRAIN_ACTIVE, DISABLE_ALL
}

var active: bool = false:
	set(a):
		if a and not active:
			# activate
			active = true
			if self in ACTIVE_POPUPS:
				push_warning("EnergyPopup went from inactive to active while still having been in ACTIVE_POPUPS.")
				return
			ACTIVE_POPUPS.push_back(self)
		if not a and active:
			# deactivate
			active = false
			self.visible = false
			size = Vector2.ZERO
			hide()
			if not self in ACTIVE_POPUPS:
				push_warning("EnergyPopup for tile %s was not in ACTIVE_POPUPS." % tile.to_string())
			ACTIVE_POPUPS.erase(self)
			
func activate(cause: ActiveCause = ActiveCause.OVERLAY):
	push_error("not yet implemented")

func deactivate(cause: ActiveCause):
	push_error("not yet implemented")

static func deactivate_all_popups():
	for i in range(len(ACTIVE_POPUPS) - 1, -1, -1):
		var popup = ACTIVE_POPUPS[i]
		popup.active = false
		
#static func activate_all_popups():
	#pass

func tile_has_energy_to_show() -> bool:
	return not tile.get_drainable_energy().is_empty()

# FIXME maybe make do without freeing/instantiating every time, but honestly should be no big deal here
const ENERGY_ICON = preload("res://UI/PopUp/EnergyIcon.tscn")
func update():
	if not is_inside_tree():
		return
	var energy: EnergyStack = tile.get_drainable_energy()
	for icon in $List.get_children():
		icon.free()
	if energy.is_empty():
		active = false
		return

	energy.sort()
	for e in energy.stack:
		var icon = ENERGY_ICON.instantiate()
		$List.add_child(icon)
		icon.show()
		icon.owner = self
		icon.type = e
		icon.min_size = icon_size

	await get_tree().process_frame
	pivot_offset = size / 2

func drain():
	# TODO for this we could play a slight animation and then slowly fade it out
	pass

func update_size_with_mouse_pos():
	var alpha := 1.0 - smoothstep(
			20, 26, tile.tile3d.global_position.distance_squared_to(MouseInput.mouse_pos_3d)
		)
	modulate.a = alpha
	for icon in $List.get_children():
		if icon is EnergyIcon:
			icon.min_size = int(alpha * 34.0)
