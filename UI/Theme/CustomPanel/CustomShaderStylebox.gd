class_name DoubleTexturedStylebox extends StyleBoxTexture

@export var shader_material: ShaderMaterial


func _init() -> void:
	pass


func _draw(canvas_item, rect):
	draw_rect(canvas_item, rect, false, Color.WHITE, false, shader_material)
