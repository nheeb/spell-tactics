extends EnemyMove

const DRAINED_TILES_COUNT = 2

var tiles: Array[Tile]

## Returns a score for the attractiveness to do the move.
func get_score() -> float:
	tiles.clear()
	tiles.append_array(combat.player.current_tile.get_surrounding_tiles().filter(\
			func (t): return t.is_drainable()))
	tiles.shuffle()
	tiles = tiles.slice(0, DRAINED_TILES_COUNT)
	if tiles:
		match enemy.type.behaviour:
			EnemyEntityType.Behaviour.Support:
				return 2.0
	return 0.0

## Executes the move
func execute() -> void:
	combat.animation.say(enemy.visual_entity, "\"I'll take his energy!\"", {"color": Color.WHITE, "font_size": 64})
	combat.animation.camera_reach(combat.player.visual_entity)
	for tile in tiles:
		combat.animation.effect(VFX.BILLBOARD_PROJECTILE, enemy.visual_entity, \
		 {"texture_name": "notes", "target": tile}).set_flag_extend()
	combat.animation.wait(.5)
	for tile in tiles:
		combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.SLATE_GRAY})
		for entity in tile.entities:
			if entity.is_drainable():
				entity.drain()
				combat.animation.callback(entity.visual_entity, "visual_drain").set_flag_with()
