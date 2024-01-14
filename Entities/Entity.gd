class_name Entity

## The EntityType (Resource) this Entity is an instance of
var type: EntityType
## The visual representation of this Entity optional (can be null).
## This Node is only part of the scene tree if this Entity has been added to a tile.
var visual_entity: VisualEntity
## optional:
var logical_entity: LogicalEntity

## Reference to the Tile this Entity is residing on
var current_tile: Tile


func to_state() -> EntityState:
	print("-- Serializing %s --" % type.internal_name)
	var state: EntityState = EntityState.new()
	
	if logical_entity != null:
		# TODO get all props from this
		pass
	
	# need to get props from visual entity? pls no, should be initialized on load
	
	for prop in get_property_list():
		print(prop)
	
	return null
	
func move(target: Tile):
	current_tile.remove_entity(self)
	target.add_entity(self)
