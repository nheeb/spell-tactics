class_name EnergyPopup extends PanelContainer

## Each EnergyPopup is responsible for adding/removing itself from this list.
## Depending on whether it's currently showing. This is mainly used by the PopupHandler
## to update the screen space position each frame.
static var ACTIVE_POPUPS: Array[EnergyPopup] = []
@export var icon_size := 38

var tile: Tile = null
var combat: Combat

# TODO change all icon's min_size on window resized!

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
