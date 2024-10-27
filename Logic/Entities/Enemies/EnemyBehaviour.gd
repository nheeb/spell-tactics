class_name EnemyBehaviour extends Resource

@export var name: String
@export var decision_power := 2.0
@export var criteria_preferences: Array[EnemyActionCriteriaValue]
var criteria_dict: Dictionary = {}: 
	get:
		if criteria_dict.is_empty():
			for cp in criteria_preferences:
				criteria_dict[cp.criteria] = cp.value
		return criteria_dict
