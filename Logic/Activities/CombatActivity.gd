class_name CombatActivity extends Activity

var combat: Combat

var level_path: String
var combat_state: CombatState

func _init(_level_path = "", _combat_state = null):
	self.level_path = _level_path
	self.combat_state = _combat_state
