class_name DrainableEntry extends PanelContainer

@export var icon_size := 38
var connected_tile: Tile = null


const ENERGY_ICON = preload("res://UI/EnergyIcon.tscn")
func show_energy(energy: EnergyStack):
	#if connected_tile.r == 6 and connected_tile.q == 6:
		#print("prev: ", len($GridContainer.get_children()))
		#print("setting: ", len(energy.stack))
	
	for icon in $GridContainer.get_children():
		icon.free()
	if energy.is_empty():
		self.visible = false
		size = Vector2.ZERO
		hide()
		return
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
	var test = 1


func reset():
	for icon in $GridContainer.get_children():
		icon.free()
	self.visible = false
	self.hide()
