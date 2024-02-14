extends EventSpellLogic

const SHROOM_STUMP = preload("res://Entities/Environment/StumpShrooms.tres")
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
		var all_stumps : Array[Entity] = combat.level.entities().get_all_active_entities().filter(func(e): return e.type.internal_name == "stump")
		if all_stumps:
			var stump : Entity = all_stumps.pick_random() as Entity
			spell.round_persistant_properties["target"] = stump.get_reference()
			combat.animation.camera_reach(stump.visual_entity)
			combat.animation.say(stump.visual_entity, "Something grows inside.", {"color": Color.YELLOW, "font": "italic"})
	else:
		var stump : Entity = combat.resolve_reference(spell.round_persistant_properties.get("target")) as Entity
		if stump == null:
			return
		var tile := stump.current_tile
		combat.animation.camera_reach(stump.visual_entity)
		
		combat.level.move_entity_to_graveyard(stump)
		var leafless := combat.level.entities().create_entity(tile.location, SHROOM_STUMP, false)
		combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW}).set_duration(1.5)
		combat.animation.hide(stump.visual_entity).set_flag_with()
		combat.animation.show(leafless.visual_entity).set_flag_with()
		spell.round_persistant_properties["target"] = null
