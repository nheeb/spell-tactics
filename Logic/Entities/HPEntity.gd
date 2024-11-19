class_name HPEntity extends Entity

signal hp_changed(hp)
signal died
@export var hp: int:
	set(h):
		hp = h
		hp_changed.emit(hp)
		if hp <= 0:
			died.emit()

var armor := 0
var team : HPEntityType.Teams

func on_load():
	await super.on_load()
	combat.animation.update_hp(self)
	#if not Engine.is_editor_hint():
		## only connect once everything is set up
		## previously the deserialization ran into errors in on_death() since
		## combat.level was still null
		#died.connect(on_death)  

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
