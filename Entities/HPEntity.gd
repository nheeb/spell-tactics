class_name HPEntity extends Entity

signal hp_changed(hp)
signal died
@export var hp: int:
	set(h):
		hp = h
		hp_changed.emit(hp)
		if hp <= 0:
			died.emit()

func on_create():
	super.on_create()
	if not Engine.is_editor_hint():
		combat.animation.update_hp(self)
		# only connect once everything is set up
		# previously the deserialization ran into errors in on_death() since
		# combat.level was still null
		died.connect(on_death)  

func on_death():
	combat.level.move_entity_to_graveyard(self)
	# TODO change this later to call death animation
	combat.animation.property(visual_entity, "visible", false)

func inflict_damage(damage: int):
	if damage == 0:
		return
	hp = hp - damage

func inflict_damage_with_visuals(damage: int) -> AnimationObject:
	inflict_damage(damage)
	return combat.animation.update_hp(self)

func inflict_heal_with_visuals(heal: int) -> AnimationObject:
	type = type as HPEntityType
	hp = min(type.max_hp, hp + heal)
	return combat.animation.update_hp(self)
