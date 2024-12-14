class_name SelectDeckActivity extends Activity


func _ready():
	pass


func _on_button_1_pressed() -> void:
	Game.deck_choice = 1
	ActivityManager.pop()
	ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))


func _on_button_2_pressed() -> void:
	Game.deck_choice = 2
	ActivityManager.pop()
	ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))
