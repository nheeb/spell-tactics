class_name HoverPopup extends Control


# no instancing for now, just max it out at 3 entries

const DRAINABLE_ENTRY = preload("res://UI/PopUp/HoverPopupEntry.tscn")

#@onready var ent_entries: Array[DrainablePopupEntry] = [%EntityEntry1, %EntityEntry2, %EntityEntry3]
func show_tile(tile: Tile):
	%TileLabel.text = "Tile (%s, %s)" % [tile.r, tile.q]
	%TileLabel.visible = Game.DEBUG_OVERLAY
	
	# reset
	hide_popup()

	var i = 0
	# tile has an array of entities, show one entry for each of these
	for ent in tile.entities:
		if ent.type.is_terrain:
			continue
		var drainable_entry: HoverPopupEntry = DRAINABLE_ENTRY.instantiate()
		%EntryContainer.add_child(drainable_entry)

		drainable_entry.name = "%2d_Drainable" % i
		if ent.type.is_drainable:
			drainable_entry.show_drainable_entity(ent)
		elif ent.type is EnemyEntityType:
			# we won't have drainable enemies, will we?
			drainable_entry.show_enemy_entity(ent)
		elif ent.type is PlayerEntityType:
			drainable_entry.show_player_entity(ent)
		else:
			push_warning("unexpected ent %s in HoverPopup, implement better filter" % str(ent))
			drainable_entry.queue_free()
			continue
			

		drainable_entry.show()

		i += 1

	# don't show if it's empty (except for tile label)
	if %EntryContainer.get_child_count() == 1:
		return
	
	show()
	self.size = Vector2(0.0, 0.0)
	%EntryContainer.size = Vector2(0, 0)
	$MarginContainer.size = Vector2(0, 0)
	await get_tree().process_frame
	# my best efforts to invalidate the container(s)
	self.size = Vector2(0.0, 0.0)
	%EntryContainer.size = Vector2(0, 0)
	$MarginContainer.size = Vector2(0, 0)
	
func hide_popup():
	hide()
	for entry in %EntryContainer.get_children():
		if not entry is Label:
			entry.queue_free()

# Try one of those calls if Container resizing fails again...
#$MarginContainer/VBoxContainer.sort_children.emit()
#self.update_minimum_size()
#$MarginContainer.update_minimum_size()
#self.set_deferred("rect_min_size", Vector2(0, 0))
#resized.emit()
#$MarginContainer.resized.emit()
#$MarginContainer/VBoxContainer.resized.emit()
