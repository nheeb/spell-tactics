class_name PlayerEntityType extends HPEntityType


## Overriding base entity method to return more specific type
func create_entity() -> PlayerEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: PlayerEntity = PlayerEntity.new()
	
	if self.visual_scene != null:
		# CARE, this might lead to lag, depending on the use we might want to instantiate later
		ent.visual_entity = self.visual_scene.instantiate()
		assert(ent.visual_entity is VisualPlayer)
		ent.hp_changed.connect(ent.visual_entity.update_hp)
		ent.visual_entity.type = self
		ent.type = self
		
	else:
		# for debugging
		ent.visual_entity = PROTOTYPE_VISUALS.instantiate()
		ent.visual_entity.type = self
		ent.type = self

	ent.hp = max_hp

	return ent
