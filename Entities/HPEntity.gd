class_name HPEntity extends Entity

signal hp_changed(hp)
signal died
@export var hp: int:
	set(h):
		hp = h
		hp_changed.emit(hp)
		# TODO
		#Game.combat.animation_queue.append(AnimationObject.new(Game.combat_ui, "set_status", ["Drawing hand cards..."]))
		if hp <= 0:
			died.emit()
			on_death()

func on_create():
	super.on_create()
	if not Engine.is_editor_hint():
		combat.animation.update_hp(self)

func on_death():
	combat.level.move_entity_to_graveyard(self)
	# TODO change this later to call death animation
	combat.animation.property(visual_entity, "visible", false)

func inflict_damage(damage: int):
	if damage == 0:
		return
	hp = hp - damage
