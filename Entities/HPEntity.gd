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
