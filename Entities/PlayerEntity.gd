class_name PlayerEntity extends HPEntity

## arch_enemy for testing
var arch_enemy : EntityReference

var traits := PlayerTraits.new()

func on_death():
	combat.animation.callback(visual_entity, "on_death_visuals")
	combat.log.add("GAME OVER!")
	combat.animation.callback(combat.ui, "show_game_over", ["You lost!"])

func on_create():
	super.on_create()
