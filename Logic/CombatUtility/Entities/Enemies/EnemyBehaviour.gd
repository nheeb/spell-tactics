class_name EnemyBehaviour extends Resource

@export var associated_enum_entry: EnemyEntityType.Behaviour
@export var criteria_preferences: Array[EnemyActionCriteriaValue]
var criteria_dict: Dictionary = {}: 
	get:
		if criteria_dict.is_empty():
			for cp in criteria_preferences:
				criteria_dict[cp.criteria] = cp.value
		return criteria_dict
