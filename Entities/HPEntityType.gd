@tool
class_name HPEntityType extends EntityType

@export var max_hp: int


## Overriding base entity method to return more specific type
func create_entity(combat: Combat, call_on_create := true) -> HPEntity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: HPEntity = HPEntity.new()
	
	ent.combat = combat
	
	if self.visual_scene != null:
		# CARE, this might lead to lag, depending on the use we might want to instantiate later
		ent.visual_entity = self.visual_scene.instantiate()
		ent.visual_entity.type = self
		ent.type = self
	else:
		# for debugging
		ent.visual_entity = Game.PROTOTYPE_VISUALS.instantiate()
		ent.visual_entity.type = self
		ent.type = self
		
	ent.hp = max_hp

	if call_on_create:
		ent.on_create()

	return ent
