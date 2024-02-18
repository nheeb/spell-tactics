extends Node3D

## Quick Paste: combat.animation.say(target, "", {"color": Color., "font_size": 64})

signal effect_done

const FONTS = {
	"regular" : preload("res://Assets/Fonts/Teachers/Teachers-Regular.ttf"),
	"bold" : preload("res://Assets/Fonts/Teachers/Teachers-ExtraBold.ttf"),
	"italic" : preload("res://Assets/Fonts/Teachers/Teachers-Italic.ttf"),
}

var text := ""
var duration := 1.0
var start_height := 2.0
var end_height := 3.0
var color := Color.WHITE
var outline_size := 0
var font_size := 64
var font := "regular"

func _ready() -> void:
	$Label3D.visible = false

func effect_start() -> void:
	duration = max(.2, duration)
	$Label3D.modulate = color
	$Label3D.outline_size = outline_size
	$Label3D.text = text
	$Label3D.font_size = font_size
	$Label3D.font = FONTS[font]
	var tween := VisualTime.new_tween()
	tween.tween_property($Label3D, "position:y", end_height, duration * 2).from(start_height)
	await VisualTime.new_timer(.01).timeout
	$Label3D.visible = true
	await VisualTime.new_timer(duration).timeout
	effect_done.emit()
	queue_free()
