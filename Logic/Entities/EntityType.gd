class_name EntityType extends CombatObjectType

## whether a UI element should pop up with name / info on hover (might belong more in VisualEntity)
@export var can_be_hovered: bool = true
## OPTIONAL, PackedScene inheriting from VisualEntity.tscn with mesh/particles/animations
@export var visual_scene: PackedScene

## Which tags (categories) this entity belongs to, for example Mushroom
@export var tags: Array[String] = []
@export var is_terrain := false

@export_group("Prototype Graphics")
@export var prototype_scale := Vector2.ONE

@export_group("Energy")
@export var is_drainable := true
## The energy this entity gives (if it's drainable)
@export var energy: EnergyStack = null

@export_group("Collision")
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

func create_base_object() -> CombatObject:
	var ent := Entity.new()
	ent.type = self
	ent.energy = ent.type.energy
	if ent.energy == null:  # give empty stack if it was left blank
		ent.energy = EnergyStack.new()
	return ent

func create(combat: Combat, props := {}) -> CombatObject:
	var ent := super(combat, props) as Entity
	assert(ent)
	setup_visuals_and_logic(ent)
	# entity_on_create(ent, false)
	return ent

# instantiate this EntityType
# usually calls on create, the flag is only for deserialize to call that function after the properties have been set
func create_entity(combat: Combat, tile: Tile = null) -> Entity:
	var ent := create(combat) as Entity
	assert(ent)
	if tile:
		tile.add_entity(ent)
	return ent

const PROTOTYPE_VISUALS = "res://VFX/Entities/VisualPrototype.tscn"
func setup_visuals(ent: Entity) -> void:
	var combat := ent.combat
	# CARE, instantiate() might lead to lag, depending on the use we might want to instantiate later
	# use billboard prototype visuals if no visual scene is set:
	if visual_scene != null:
		ent.visual_entity = visual_scene.instantiate()
	else:
		# push_warning("Using a prototype visual")
		# need to use load here since Godot 4.3 for some reason..
		ent.visual_entity = load(PROTOTYPE_VISUALS).instantiate()
		
	# hehehe - but these references are safe since entity and visual entity exists together
	if ent.visual_entity == null or "type" not in ent.visual_entity:
		push_error("Error in initializing VisualEntity '%s', maybe it's missing VisualEntity.gd assignment?" % internal_name)
		return
	ent.visual_entity.type = self
	ent.visual_entity.entity = ent
	ent.visual_entity.visible = false
	#combat.animation.show(ent.visual_entity)


func setup_visuals_and_logic(ent: Entity) -> void:
	setup_visuals(ent)

	# Creating entity logic
	if logic_script != null:
		ent.logic = logic_script.new(ent, ent.combat)


func entity_on_create(ent: Entity, call_on_create: bool) -> void:
	if call_on_create:
		ent.on_create()
		if ent.logic:
			ent.logic.on_create()

func get_prototype_texture():
	var texture_path := "res://Assets/Sprites/PrototypeBillboard/" + internal_name + ".png"
	return load(texture_path)
