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

func on_create():
	super.on_create()
	if not Engine.is_editor_hint():
		combat.animation.update_hp(self)
		# only connect once everything is set up
		# previously the deserialization ran into errors in on_death() since
		# combat.level was still null
		died.connect(on_death)  

func on_death():
	# TODO change this later to call death animation
	combat.animation.property(visual_entity, "visible", false)
	if logic:
		if logic.has_method("on_death"):
			logic.on_death()
	combat.level.move_entity_to_graveyard(self)
	

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
	if not with_text:
		return combat.animation.update_hp(self)
	else:
		return combat.animation.reappend_as_subqueue([
			combat.animation.update_hp(self),
			combat.animation.say(self.visual_entity, "%s Damage" % damage,\
		 		{"color": Color.RED, "font_size": 64}).set_duration(.5).set_flag_with()
		])

func inflict_heal_with_visuals(heal: int) -> AnimationObject:
	type = type as HPEntityType
	hp = min(type.max_hp, hp + heal)
	return combat.animation.update_hp(self)

func sync_with_type() -> void:
	super()
	hp = type.max_hp
	combat.animation.update_hp(self)
