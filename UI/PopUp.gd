extends Control


# no instancing for now, just max it out at 3 entries
const ENT_ENTRY = preload("res://UI/PopUp/PopUpEntityEntry.tscn")

@onready var ent_entries = [%EntityEntry1, %EntityEntry2, %EntityEntry3]
func show_tile(tile: Tile):
	%TileLabel.text = "Tile (%s, %s)" % [tile.r, tile.q]
	
	var i = 0
	# tile has an array of entities, show one entry for each of these
	for ent in tile.entities:
		if ent.type.is_terrain:
			# skip terrain entities (for now?)
			continue
		ent_entries[i].show_entity(ent)
		ent_entries[i].show()
		i += 1
	
	# hide entries without entities
	# if there are no entities on this tile, i will be 0, so all entries will be hidden
	for j in range(i, len(ent_entries)):
		ent_entries[j].hide()
	
	await get_tree().process_frame
	# my best efforts to invalidate the container(s)
	self.update_minimum_size()
	$MarginContainer/VBoxContainer.update_minimum_size()
	$MarginContainer/VBoxContainer.sort_children.emit()
	$MarginContainer.update_minimum_size()
	self.set_deferred("rect_min_size", Vector2(0, 0))
	resized.emit()
	$MarginContainer.resized.emit()
	$MarginContainer/VBoxContainer.resized.emit()

func hide_popup():
	hide()
	for j in range(0, len(ent_entries)):
		ent_entries[j].hide()
