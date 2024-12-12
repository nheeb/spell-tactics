extends Control

func _ready() -> void:
	ActivityManager.push(RootActivity.new())
	if Game.DEBUG_SPELL_TESTING:
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_SPELLTEST))
	else:
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))
