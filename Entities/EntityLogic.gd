class_name EntityLogic

var entity: Entity
var combat: Combat


func _init(e: Entity, c: Combat) -> void:
	entity = e
	combat = c
	# connect to entity entering the graveyard
	e.entered_graveyard.connect(on_graveyard)

func on_graveyard():
	# override me :)
	pass

## Each LogicalEntity can connect itself to combat here
func on_create():
	pass

func get_reference() -> PropertyReference:
	return PropertyReference.new(entity.get_reference(), "logic")
