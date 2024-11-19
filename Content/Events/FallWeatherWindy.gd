extends CombatEventLogic

const TREE = preload("res://Content/Entities/Tree.tres")
const LEAFLESS = preload("res://Content/Entities/LeaflessTree.tres")
const FOLIAGE = preload("res://Content/Entities/Foliage.tres")

func _on_advance(round_number: int) -> void:
	var all_trees : Array[Entity] = combat.level.entities.get_all_active_entities().filter(
		func(e): return e.type == TREE
	)
	if all_trees:
		var tree : Entity = all_trees.pick_random() as Entity
		combat.animation.camera_reach(tree.visual_entity)
		combat.animation.say(tree.visual_entity, "The leaves tremble in the wind.", {"color": Color.YELLOW, "font": "italic"})
		var tile := tree.current_tile
		combat.level.move_entity_to_graveyard(tree)
		
		var leafless := LEAFLESS.create_entity(combat, tile)
		combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_duration(1.0)
		combat.animation.hide(tree.visual_entity).set_flag_with()
		combat.animation.show(leafless.visual_entity).set_flag_with()
		await combat.action_stack.wait()
		
		var free_tiles : Array[Tile] = tile.get_surrounding_tiles().filter(func (t): return not t.is_obstacle())
		free_tiles.shuffle()
		free_tiles = free_tiles.slice(0, 3)
		for t in free_tiles:
			var foliage := FOLIAGE.create_entity(combat, t)
			combat.animation.effect(VFX.HEX_RINGS, t, {"color": Color.GREEN}).set_duration(.3)
			combat.animation.show(foliage.visual_entity).set_flag_with()
			await combat.action_stack.wait()
