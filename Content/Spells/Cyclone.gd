extends SpellLogic

const CYCLONE = preload("res://Content/Entities/Cyclone.tres")
func execute() -> void:
	# later: add animation callback/effect for fading in the cyclone
	CYCLONE.create_entity(combat, target_tile)
