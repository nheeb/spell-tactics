class_name HPEntityType extends EntityType

@export var max_hp: int


## Overriding base entity method to return more specific type
func create_entity() -> HPEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: HPEntity = HPEntity.new()
	
	if self.visual_scene != null:
		# CARE, this might lead to lag, depending on the use we might want to instantiate later
		ent.visual_entity = self.visual_scene.instantiate()
		ent.visual_entity.type = self
		ent.type = self
	else:
		# for debugging
		ent.visual_entity = PROTOTYPE_VISUALS.instantiate()
		ent.visual_entity.type = self
		ent.type = self
		
	ent.hp = max_hp

	return ent
