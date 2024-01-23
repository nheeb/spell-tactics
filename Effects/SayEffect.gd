extends Node3D

signal effect_done

var text := ""
var duration := 1.7
var start_height := 2.0
var end_height := 3.0

func _ready() -> void:
	$Label3D.visible = false

func effect_start() -> void:
	duration = max(.2, duration)
	$Label3D.text = text
	var tween := VisualTime.new_tween()
	tween.tween_property($Label3D, "position:y", end_height, duration).from(start_height)
	await VisualTime.new_timer(.05).timeout
	$Label3D.visible = true
	await tween.finished
	effect_done.emit()
	queue_free()
