extends SpellLogic


const CYCLONE = preload("res://Content/Entities/Cyclone.tres")
func casting_effect() -> void:
	combat.animation.call_method(combat.ui, "set_status", ["Creating cyclone.."])
	# later: add animation callback/effect for fading in the cyclone
	combat.level.entities.create((target as Tile).location, CYCLONE)
	
