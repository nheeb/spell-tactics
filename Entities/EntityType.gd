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
	setup_visuals_and_logic(ent, combat)
	entity_on_create(ent, call_on_create)
	return ent

func setup_visuals_and_logic(ent: Entity, combat: Combat) -> void:
	ent.combat = combat
	# CARE, instantiate() might lead to lag, depending on the use we might want to instantiate later
	# use billboard prototype visuals if no visual scene is set:
	ent.visual_entity = self.visual_scene.instantiate()	if self.visual_scene != null else Game.PROTOTYPE_VISUALS.instantiate()
	# hehehe - but these references are safe since entity and visual entity exists together
	if "type" not in ent.visual_entity:
		push_error("Error in initializing VisualEntity for type %s, maybe it's missing VisualEntity.gd assignment?" % internal_name)
	ent.visual_entity.type = self
	ent.visual_entity.entity = ent
	ent.type = self

	if self.entity_logic != null:
		ent.logic = self.entity_logic.new(ent, combat)

	ent.energy = ent.type.energy
	if ent.energy == null:  # give empty stack if it was left blank
		ent.energy = EnergyStack.new()

func entity_on_create(ent: Entity, call_on_create: bool) -> void:
	if call_on_create:
		ent.on_create()
		if ent.logic:
			ent.logic.on_create()

func get_prototype_texture():
	var texture_path := "res://Assets/Sprites/PrototypeBillboard/" + internal_name + ".png"
	return load(texture_path)
