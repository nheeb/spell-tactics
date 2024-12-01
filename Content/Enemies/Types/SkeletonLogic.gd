extends EntityLogic

const SKULL = preload("res://Content/Entities/Skull.tres")

func on_birth():
	combat.t_effects.add_effect(
		TimedEffect.new_end_phase_trigger_from_callable(decay).set_owner(entity)
	)

func on_death(): # Happens when HP Entity dies
	var tile := entity.current_tile
	var skull := combat.level.entities.create(tile.location, SKULL, false)
	combat.animation.show(skull.visual_entity).set_flag_with()
	combat.animation.effect(VFX.HEX_RINGS, tile, {"color": Color.YELLOW})\
		.set_max_duration(.5).set_flag_extend()

func decay():
	var enemy := entity as EnemyEntity
	if enemy:
		combat.animation.say(enemy.visual_entity, "Decay")
		enemy.inflict_damage_with_visuals(1).set_flag_with().set_delay(.3)
