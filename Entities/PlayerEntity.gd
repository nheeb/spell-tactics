class_name PlayerEntity extends HPEntity

#var secret_msg = "serialize me"
#
#var prop := -1

## arch_enemy for testing
var arch_enemy : EntityReference

var traits := PlayerTraits.new()

func on_death():
	# TODO Game over mechanic
	combat.log.add("GAME OVER!")
