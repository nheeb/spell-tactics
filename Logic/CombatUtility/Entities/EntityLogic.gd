class_name EntityLogic

var entity: Entity
var combat: Combat

func _init(e: Entity, c: Combat) -> void:
	entity = e
	combat = c
	# connect to entity entering the graveyard
	e.entered_graveyard.connect(on_graveyard)

func on_graveyard():
	pass

## Executed when the logic is created or loaded (Put visuals in here)
func on_create():
	pass

## Executed when the logic / entity is create ingame (Put logic in here)
func on_summon():
	pass

func get_reference() -> PropertyReference:
	return PropertyReference.new(entity.get_reference(), "logic")
