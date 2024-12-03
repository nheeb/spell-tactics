extends CombatEventLogic

const TREE = preload("res://Content/Entities/Tree.tres")
const LEAFLESS = preload("res://Content/Entities/LeaflessTree.tres")
const FOLIAGE = preload("res://Content/Entities/Foliage.tres")

func _on_advance(round_number: int) -> void:
	var all_trees : Array[Entity] = combat.level.entities.get_all_active_entities().filter(
		func(e): return e.type == TREE
	)
	if all_trees:
		all_trees.shuffle()
		# get a third (max 4)
		var count := min(4, int(all_trees.size() / 3.0) + 1) as int
		for tree: Entity in all_trees.slice(0, count):
			await combat.action_stack.wait()
			combat.animation.wait(.3)
			var tile := tree.current_tile
			combat.level.move_entity_to_graveyard(tree)
			
			var leafless := LEAFLESS.create_entity(combat, tile)
			combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_flag_with()
			combat.animation.hide(tree.visual_entity).set_flag_with()
			combat.animation.show(leafless.visual_entity).set_flag_with()
			
			combat.animation.wait(.3)
			var free_tiles : Array[Tile] = tile.get_surrounding_tiles().filter(
				func (t: Tile): return not t.is_blocked()
			)
			free_tiles.shuffle()
			free_tiles = free_tiles.slice(0, 3)
			for t in free_tiles:
				var foliage := FOLIAGE.create_entity(combat, t)
				combat.animation.effect(VFX.HEX_RINGS, t, {"color": Color.GREEN}).set_flag_with()
				combat.animation.show(foliage.visual_entity).set_flag_with()
