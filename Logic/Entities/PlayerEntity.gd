class_name PlayerEntity extends HPEntity

var traits := PlayerTraits.new()

func on_death():
	combat.animation.call_method(visual_entity, "on_death_visuals")
	combat.log.add("GAME OVER!")
	combat.animation.call_method(combat.ui, "show_game_over", ["You lost!"])

func on_create():
	super.on_create()