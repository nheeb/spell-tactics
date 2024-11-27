class_name EnergyPopup extends PanelContainer

## Each EnergyPopup is responsible for adding/removing itself from this list.
## Depending on whether it's currently showing. This is mainly used by the PopupHandler
## to update the screen space position each frame.
static var active_popups: Array[EnergyPopup] = []

@export var icon_size := 38
var connected_tile: Tile = null

var active: bool:
	set(a):
		if a and not active:
			# activate
			active = true
		if not a and active:
			# deactivate
			active = false
			self.visible = false
			size = Vector2.ZERO
			hide()
			active_popups.erase(self)

# TODO maybe make do without freeing/instantiating every time, but honestly should be no big deal here
const ENERGY_ICON = preload("res://UI/PopUp/EnergyIcon.tscn")
func update_energy(): 
	var energy: EnergyStack = connected_tile.get_drainable_energy()
	for icon in $GridContainer.get_children():
		icon.free()
	if energy.is_empty():
		active = false
		return
	active = true
	energy.sort()
	for e in energy.stack:
		var icon = ENERGY_ICON.instantiate()
		$GridContainer.add_child(icon)
		icon.show()
		icon.owner = self
		icon.type = e
		icon.min_size = icon_size
	
	
	await get_tree().process_frame
	pivot_offset = size / 2

func drain():
	# TODO for this we could play a slight animation and then slowly fade it out
	pass
