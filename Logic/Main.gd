extends Control

func _ready() -> void:
	ActivityManager.push(RootActivity.new())
	if Game.DEBUG_SPELL_TESTING:
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_SPELLTEST))
	
	elif Game.DEBUG_SKIP_DECKSELECTION:
		Game.deck_choice = 1
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))
		
	else:
		ActivityManager.push(SelectDeckActivity.new())
