extends EntityLogic

func on_create(): # Executed when the entity is created (deserialized or summoned)
	pass # visuals here

func on_summon(): # Executed when the entity is created (deserialized or summoned)
	pass # logic here

func on_graveyard(): # Executed when the entity enters the graveyard
	pass

# Only for HP Entity
#func on_death(): # Executed when hp entity dies (before its being moved to the graveyard)
	#pass
