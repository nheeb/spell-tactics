class_name EntityType extends Resource

@export_category("Entity")
## Lowercase unique entity identifier
@export var internal_name: String
## whether a UI element should pop up with name / info on hover (might belong more in VisualEntity)
@export var can_be_hovered: bool = true
## Name that will be shown ingame (for example when hovering)
@export var pretty_name: String
## OPTIONAL, fluff text shown on hovering over the entity
@export_multiline var fluff_text: String
## OPTIONAL, PackedScene inheriting from VisualEntity.tscn with mesh/particles/animations
@export var visual_scene: PackedScene
## OPTIONAL, logic script inheriting from EntityLogic for special behavior
@export var entity_logic: Script

@export_category("Gameplay")
@export var is_drainable := true
## The energy this entity gives (if it's drainable)
@export var energy: Array[Game.Energy]

## Whether the player / enemies can move onto tiles containing this entity
@export var is_obstacle: bool = false
## How good of a cover this is from projectiles (accuracy reduction)
@export_range(1, 3, 1) var cover_value: int = 0

## instantiate this EntityType
const PROTOTYPE_VISUALS = preload("res://Entities/Visuals/VisualPrototype.tscn")
func to_entity() -> Entity:
	# instance visual entity, who adds this to the scene tree?
	# I think we should have a method add_entity() in Tile
	var ent: Entity = Entity.new()
	
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

	return ent
