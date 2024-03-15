class_name CardChoiceActivity extends CombatChoiceActivity

var count_min: int
var count_max: int

var cards: Cards3D

func _init(_cards: Cards3D, _min: int, _max: int = -1) -> void:
	cards = _cards
	count_min = _min
	count_max = _min if _max == -1 else _max
	assert(count_min >= 0 and count_max > 0)
