extends EntityLogic

func on_create(): # Happens when the entity is created (deserialized or summoned)
	pass

func on_delete(): # Happens when the entity enters the graveyard
	pass

func on_death(): # Happens when hp entity dies (before its being moved to the graveyard)
	pass
