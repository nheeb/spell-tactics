extends Control


func _ready() -> void:
	ActivityManager.push(RootActivity.new())
	if Game.DEBUG_SPELL_TESTING:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_SPELLTEST))
	elif Game.DEBUG_SKIP_OVERWORLD:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))
	elif Game.DEBUG_SKIP_POST_COMBAT:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new(Game.LEVEL_PATH_DEFAULT))
		ActivityManager.substitute(PostCombatActivity.new())
	elif Game.DEBUG_DECK_VIEW:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(BrowseDeckActivity.new())
	elif Game.DEBUG_DECK_PURGE:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(PurgeDeckActivity.new(20, false))
