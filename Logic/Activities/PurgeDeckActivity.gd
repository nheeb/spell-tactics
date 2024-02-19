class_name PurgeDeckActivity extends Activity

var num: int = 0
var allow_back: bool = false

func _init(_num, _allow_back):
	num = _num
	allow_back = _allow_back

func process_result(spell_states: Array[SpellState]):
	Adventure.remove_cards(spell_states)
	ActivityManager.pop()

