class_name EnemyActionEval extends Object

enum Criteria {
	Damage,
	MoveToFoe,
	MoveFromFoe,
	EnergyGrief,
	Buff,
	Debuff,
	Charge,
	Minion,
	Objective,
	Forced,
	Disrespect,
	Bonus,
	Sustain,
}

var scores: Dictionary = {} # Criteria -> Score (float)

func _init(_scores := {}) -> void:
	scores = _scores
	assert(scores.keys().all(func (c): return c is Criteria))
	assert(scores.values().all(func (v): return v is float))

func get_total_score(behaviour: EnemyBehaviour) -> float:
	var behaviour_dict := {}
	if behaviour:
		behaviour_dict = behaviour.criteria_dict
	var total_score := 0.0
	for c in Criteria.values():
		total_score +=  Utility.dict_safe_get(scores, c, 0.0) * \
						Utility.dict_safe_get(behaviour_dict, c, 0.0)
	return max(0.0, total_score)

static func from_cv_array(cvs: Array[EnemyActionCriteriaValue]) -> EnemyActionEval:
	var _scores := {}
	for cv in cvs:
		_scores[cv.criteria] = cv.value
	return EnemyActionEval.new(_scores)

func add(eval: EnemyActionEval) -> EnemyActionEval:
	for k in eval.scores.keys():
		scores[k] = Utility.dict_safe_get(scores, k, 0.0) + eval.scores[k]
	return self
