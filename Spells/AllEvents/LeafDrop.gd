extends EventSpellLogic

const LEAFLESS = preload("res://Entities/Environment/LeaflessTree.tres")
const FOLIAGE = preload("res://Entities/Environment/Foliage.tres")

## Usable references:
## spell - Corresponding event
##   (with round_persistant_properties)
## combat - The current combat for which the spell was created


## For overriding to give the event length (Could be also moved to SpellRes)
func get_event_length() -> int:
	return 2

## Most important function for overwriting. Here should be the event effect
func event_effect(round_number: int) -> void:
	if round_number <= 1:
		var all_trees : Array[Entity] = combat.level.entities().get_all_active_entities().filter(func(e): return e.type.internal_name == "tree")
		if all_trees:
			var tree : Entity = all_trees.pick_random() as Entity
			spell.round_persistant_properties["target"] = tree.get_reference()
			combat.animation.camera_reach(tree.visual_entity)
			combat.animation.say(tree.visual_entity, "The leaves tremble in the wind.", {"color": Color.YELLOW, "font": "italic"})
	else:
		var tree : Entity = combat.resolve_reference(spell.round_persistant_properties.get("target")) as Entity
		if tree == null:
			return
		var tile := tree.current_tile
		combat.animation.camera_reach(tree.visual_entity)
		
		combat.level.move_entity_to_graveyard(tree)
		var leafless := combat.level.entities().create_entity(tile.location, LEAFLESS, false)
		combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_duration(1.5)
		combat.animation.hide(tree.visual_entity).set_flag_with()
		combat.animation.show(leafless.visual_entity).set_flag_with()
		
		var free_tiles : Array[Tile] = tile.get_surrounding_tiles().filter(func (t): return not t.is_obstacle())
		free_tiles.shuffle()
		free_tiles = free_tiles.slice(0, 3)
		for t in free_tiles:
			var foliage := combat.level.entities().create_entity(t.location, FOLIAGE, false)
			combat.animation.effect(VFX.HEX_RINGS, t, {"color": Color.GREEN}).set_duration(.7)
			combat.animation.show(foliage.visual_entity).set_flag_with()
