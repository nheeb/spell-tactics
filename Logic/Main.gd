extends Control


func _ready() -> void:
	ActivityManager.push(RootActivity.new())
	if Game.DEBUG_SPELL_TESTING:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Levels/SpellTesting/spell_test.tres"))
	elif Game.DEBUG_SKIP_OVERWORLD:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Levels/Area1/clearing.tres"))
	elif Game.DEBUG_SKIP_POST_COMBAT:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(CombatActivity.new("res://Levels/Area1/clearing.tres"))
		ActivityManager.substitute(PostCombatActivity.new())
	elif Game.DEBUG_DECK_VIEW:
		ActivityManager.push(OverworldActivity.new())
		ActivityManager.push(BrowseDeckActivity.new())
