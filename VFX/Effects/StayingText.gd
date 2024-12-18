extends StayingVisualEffect

const FONTS = {
	"regular" : preload("res://Assets/Fonts/Teachers/Teachers-Regular.ttf"),
	"bold" : preload("res://Assets/Fonts/Teachers/Teachers-ExtraBold.ttf"),
	"italic" : preload("res://Assets/Fonts/Teachers/Teachers-Italic.ttf"),
}

var text := ""
var duration := 1.2
var height := 1.65
var color := Color.WHITE
var outline_size := 0
var font_size := 48
var font := "regular"

func _ready() -> void:
	$Label3D.visible = false

func effect_start() -> void:
	$Label3D.position.y = height
	$Label3D.modulate = color
	$Label3D.outline_size = outline_size
	$Label3D.text = text
	$Label3D.font_size = font_size
	$Label3D.font = FONTS[font]
	$Label3D.visible = true
	effect_done.emit()

func on_effect_end() -> void:
	effect_died.emit()
	queue_free()
