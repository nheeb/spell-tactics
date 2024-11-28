class_name HPEntity extends Entity

@export var hp: int
@export var armor := 0
@export var team : HPEntityType.Teams

func on_load():
	await super.on_load()
	combat.animation.update_hp(self)

func on_death():
	combat.animation.call_method(visual_entity, "on_death_visuals")
	await super()

func inflict_damage(damage: int):
	if damage <= 0:
		return
	var new_armor = max(0, armor - damage)
	damage -= armor
	armor = new_armor
	if damage <= 0:
		return
	hp = hp - damage

func inflict_damage_with_visuals(damage: int, with_text := false) -> AnimationObject:
	inflict_damage(damage)
	var animations = []
	animations.append(combat.animation.update_hp(self))
	animations.append(combat.animation.call_method(visual_entity, "on_hurt_visuals"))
	if with_text:
		animations.append(combat.animation.say(self.visual_entity, "%s Damage" % damage,\
		 		{"color": Color.RED, "font_size": 64}).set_duration(.5).set_flag_with())
	
	return combat.animation.reappend_as_subqueue(animations)

func inflict_heal_with_visuals(heal: int) -> AnimationObject:
	type = type as HPEntityType
	hp = min(type.max_hp, hp + heal)
	return combat.animation.update_hp(self)

func is_wounded() -> bool:
	return hp < type.max_hp 

func on_birth():
	await super()
	TimedEffect.new_combat_change(check_hp) \
		.set_id("_cc_check_hp").set_solo().register(combat)

## TE
func check_hp():
	if hp <= 0:
		await combat.action_stack.process_callable(die)
