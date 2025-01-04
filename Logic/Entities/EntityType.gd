class_name EntityType extends CombatObjectType

## OPTIONAL, PackedScene inheriting from VisualEntity.tscn with mesh/particles/animations
@export var visual_scene: PackedScene

@export_group("Category")
## Which tags (categories) this entity belongs to, for example Mushroom
@export var tags: Array[String] = []
@export var is_terrain := false
## whether a UI element should pop up with name / info on hover (might belong more in VisualEntity)
@export var can_be_hovered: bool = true
@export var can_interact: bool = false
@export var destroy_on_interact: bool = false
@export var interact_hint := ""
enum Teams {Neutral = 0, Good = 1, Evil = 2}
@export var team := Teams.Neutral

@export_group("Prototype Graphics")
## Scale of the billboard
@export var prototype_scale := Vector2.ONE
## Modulate of the billboard
@export var prototype_modulate := Color.WHITE
## Prototype billboard is only visible in the LevelEditor
@export var only_show_in_editor := false

@export_group("Energy")
@export var is_drainable := true
## The energy this entity gives (if it's drainable)
@export var energy: EnergyStack = null
## This entity will be destroyed after getting drained
@export var destroy_on_drain := false

@export_group("Collision")
const NAV_OBSTACLE_LAYER = 1
const ENEMY_LAYER = 2
## The obstacle layer for collisions.
@export_flags_2d_physics var obstacle_layer: int = 0
## The default obstacle layer mask for grid search.
@export_flags_2d_physics var obstacle_mask: int = 0
## Whether the player / enemies can move (just) ONTO tiles containing this entity
@export var is_blocker: bool = false

@export_group("Destruction")
## Has hp and will be destroyed when hp reaches 0
@export var has_hp := false
## This entity will be spawned on death
@export var corpse_state: EntityState
## Starting hp & max hp for healing
@export var max_hp: int = 1
## If this is false hp bar will only be shown when hovered or getting damaged
@export var always_show_hp := false
## Floating height above the ground in meter
@export var hp_bar_height := 1.5
## Value for size or height when it comes to taking damage being applied to a tile
@export var cover_value: int = 0


func create_base_object() -> CombatObject:
	return Entity.new()

func set_type_properties(object: CombatObject) -> void:
	var ent := object as Entity
	assert(ent)
	ent.energy = ent.type.energy
	if ent.energy == null:  # give empty stack if it was left blank
		ent.energy = EnergyStack.new()
	if has_hp:
		ent.max_hp = max_hp
		ent.hp = max_hp
		ent.cover = cover_value
	ent.team = team
	ent.can_interact = can_interact

func create(combat: Combat, props := {}) -> CombatObject:
	var ent := super(combat, props) as Entity
	assert(ent)
	setup_visuals(ent)
	return ent

# instantiate this EntityType
# usually calls on create, the flag is only for deserialize to call that function after the properties have been set
func create_entity(combat: Combat, tile: Tile = null) -> Entity:
	var ent := create(combat) as Entity
	assert(ent)
	if tile:
		tile.add_entity(ent)
	return ent

const PROTOTYPE_VISUALS = preload("res://VFX/Entities/VisualPrototype.tscn")
func setup_visuals(ent: Entity) -> void:
	# CAUTION, instantiate() might lead to lag, depending on the use we might want to instantiate later
	# use billboard prototype visuals if no visual scene is set:
	if visual_scene != null:
		ent.visual_entity = visual_scene.instantiate()
	else:
		ent.visual_entity = PROTOTYPE_VISUALS.instantiate()
	if not ent.visual_entity:
		push_error("Error in initializing VisualEntity '%s', maybe it's missing VisualEntity.gd assignment?" % internal_name)
		return
	if ent.visual_entity.has_method("_ready"):
		ent.visual_entity._ready()
	ent.visual_entity.setup(ent)
	ent.combat.animation.show(ent.visual_entity).set_flag_with()
