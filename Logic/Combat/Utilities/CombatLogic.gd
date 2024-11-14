class_name CombatLogic extends RefCounted

# TODO make it work for logics created dynamically during the game.

var combat: Combat
# TBD do we want to use a setter for that?
# Do we even want _cc reaction on logics?
	#set(_combat):
		#if _combat:
			#combat = _combat
			#combat.action_stack.push_front(_on_combat_connect)

func setup(co: CombatObject):
	connect_with_combat_object(co)
	connect_with_combat(co.combat)

func connect_with_combat_object(co: CombatObject):
	pass

func connect_with_combat(_combat: Combat):
	assert(combat == null, "CombatLogic was already connected to combat.")
	combat = _combat

### ACTION
#func _on_combat_connect() -> void:
	#TimedEffect.new_combat_change(_on_combat_change)\
		#.force_freshness().set_id("_cc").set_solo().register(combat)
#
### TE
#func _on_combat_change() -> void:
	#pass
