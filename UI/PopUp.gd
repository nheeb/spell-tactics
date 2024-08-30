extends Control


# no instancing for now, just max it out at 3 entries
const ENT_ENTRY = preload("res://UI/PopUp/PopUpEntityEntry.tscn")

@onready var ent_entries = [%EntityEntry1, %EntityEntry2, %EntityEntry3]
func show_tile(tile: Tile):
	%TileLabel.text = "Tile (%s, %s)" % [tile.r, tile.q]
	
	if len(tile.entities) > 3:
		push_warning("PopUp show_tile() only supports up to 3 Entities.")
		return
	
	var i = 0
	# tile has an array of entities, show one entry for each of these
	for ent in tile.entities:
		if not ent.type.is_drainable:
			# skip
			continue
		ent_entries[i].show_entity(ent)
		ent_entries[i].show()
		i += 1
	
	# hide entries without entities
	# if there are no entities on this tile, i will be 0, so all entries will be hidden
	for j in range(i, len(ent_entries)):
		ent_entries[j].hide()
	
	show()
	self.size = Vector2(0.0, 0.0)
	$MarginContainer/VBoxContainer.size = Vector2(0, 0)
	$MarginContainer.size = Vector2(0, 0)
	await get_tree().process_frame
	# my best efforts to invalidate the container(s)
	self.size = Vector2(0.0, 0.0)
	$MarginContainer/VBoxContainer.size = Vector2(0, 0)
	$MarginContainer.size = Vector2(0, 0)
	
func hide_popup():
	hide()
	for j in range(0, len(ent_entries)):
		ent_entries[j].hide()

# Try one of those calls if Container resizing fails again...
#$MarginContainer/VBoxContainer.sort_children.emit()
#self.update_minimum_size()
#$MarginContainer.update_minimum_size()
#self.set_deferred("rect_min_size", Vector2(0, 0))
#resized.emit()
#$MarginContainer.resized.emit()
#$MarginContainer/VBoxContainer.resized.emit()
