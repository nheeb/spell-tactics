extends Control

func inspect_entity(ent: Entity):
	# inspect both logical and visual? 
	# let's start with visual
	var props = Utils.get_exported_properties(ent.visual_entity)
