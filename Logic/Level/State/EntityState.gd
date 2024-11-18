class_name EntityState extends CombatObjectState

## States of the Entity's Status
@export var status_states: Array[CombatObjectState] = []

func deserialize(combat: Combat) -> Entity:
	var entity: Entity = super(combat) as Entity
	assert(entity)
	for status_state in status_states:
		var status := status_state.deserialize(combat) as EntityStatus
		assert(status)
		entity.status_array.append(status)
	return entity
