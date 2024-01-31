class_name EntityLogic

var entity: Entity
var combat: Combat


func _init(e: Entity, c: Combat) -> void:
	entity = e
	combat = c
	# connect to entity entering the graveyard
	e.entered_graveyard.connect(on_delete)


func on_delete():
	# override me :)
	pass

## Each LogicalEntity can connect itself to combat here
func on_create():
	pass


