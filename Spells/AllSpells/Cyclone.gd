extends SpellLogic


const CYCLONE = preload("res://Entities/Environment/Cyclone.tres")
func casting_effect() -> void:
	combat.animation.callback(combat.ui, "set_status", ["Creating cyclone.."])
	# later: add animation callback/effect for fading in the cyclone
	combat.level.entities.create_entity((target as Tile).location, CYCLONE)
	

