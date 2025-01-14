class_name EnemyEntityState extends EntityState

## States of the Enemy's Actions
@export var action_states: Array[CombatObjectState] = []

func _init(object: CombatObject = null) -> void:
	var entity := object as EnemyEntity
	assert(entity)
	super(entity)
	for action in entity.action_pool:
		action_states.append(action.serialize())

func deserialize(combat: Combat) -> EnemyEntity:
	assert(type is EnemyEntityType)
	var entity: EnemyEntity = super(combat) as EnemyEntity
	assert(entity)
	for action_state in action_states:
		var action := action_state.deserialize(combat) as EnemyAction
		assert(action)
		entity.action_pool.append(action)
	return entity

func create_on_tile(tile: Tile) -> Entity:
	var entity := deserialize(tile.combat)
	assert(entity)
	tile.add_entity(entity)
	return entity
