class_name Settings extends Resource

const RENDER_RESOLUTIONS = [
	Vector2i(1920, 1080),
	Vector2i(2560, 1440)
]
## resolution/size of the 3D Viewport in CombatActivity
signal changed_render_resolution(res: Vector2i)
@export var render_resolution: int = 0:  # index into render_resolutions array
	set(idx):
		render_resolution = idx
		emit_changed()
		changed_render_resolution.emit(RENDER_RESOLUTIONS[idx])
## default animation speed. can still be changed during combat (with TAB probably)
@export var animation_speed: float


# probably not needed:
#func apply_to_game():
	#pass
