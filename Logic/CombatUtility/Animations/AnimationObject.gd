class_name AnimationObject extends Object

## This is the abstract Animation Object

signal animation_done

enum Flags {
	PlayAfterStep,
	PlayWithStep,
	ExtendStep
}

var flag: Flags = Flags.PlayAfterStep
var delay := 0.0
var success := false

func set_flag(f: Flags) -> AnimationObject:
	flag = f
	return self

func has_flag(f: Flags) -> bool:
	return f == flag

func set_delay(d: float) -> AnimationObject:
	if d <= 0.0:
		printerr("Invalid Animation delay")
	delay = d
	return self

func play(level: Level) -> void:
	pass

func _to_string() -> String:
	return "Anim: Abstract Animation Object"
