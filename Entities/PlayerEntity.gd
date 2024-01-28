class_name PlayerEntity extends HPEntity

## arch_enemy for testing
var arch_enemy : EntityReference

var traits := PlayerTraits.new()

func on_death():
	# TODO Game over mechanic
	combat.log.add("GAME OVER!")

func on_create():
	super.on_create()
