@tool
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

@export_category("Prototype Graphics")
@export var prototype_scale := Vector2.ONE

@export_category("Gameplay")
@export var is_terrain := false
@export var is_drainable := true
## The energy this entity gives (if it's drainable)
@export var energy: EnergyStack = null


const NAV_OBSTACLE_LAYER = 1
const ENEMY_LAYER = 2

## The obstacle layer for collisions.
@export_flags_2d_physics var obstacle_layer: int = 0
## The default obstacle layer mask for grid search.
@export_flags_2d_physics var obstacle_mask: int = 0
## Whether the player / enemies can move (just) ONTO tiles containing this entity
@export var is_blocker: bool = false
## How good of a cover this is from projectiles (accuracy reduction)
@export var cover_value: int = 0

## Which tags (categories) this entity belongs to, for example Mushroom
@export var tags: Array[String] = []

# instantiate this EntityType
# usually calls on create, the flag is only for deserialize to call that function after the properties have been set
func create_entity(combat: Combat, call_on_create := true) -> Entity:
	var ent: Entity = Entity.new()
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
		
	if self.entity_logic != null:
		ent.logic = self.entity_logic.new()
		ent.logic.combat = combat
		ent.logic.entity = ent
		ent.logic.on_create()

	
	ent.energy = ent.type.energy

	if call_on_create:
		ent.on_create()

	return ent
