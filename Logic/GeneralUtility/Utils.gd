## For static Util functions :) Could move most of Utility singleton functions into here. (Those not accessing the tree/viewport)
## This file is needed because you can't assign the return value of a static function to a static variable, when that static func is inside an autoload. Godot🙄
class_name UtilsOld

## Creates a signal without needing to bind it to an instance. This means the signal can be assigned to a static var and accessed globally. `cls` should be a global class identifier. 
##
## Taken from https://stackoverflow.com/questions/77026156/how-to-write-a-static-event-emitter-in-gdscript
static func create_static_signal(cls: Object, signal_name: StringName) -> Signal:
	if not cls.has_user_signal(signal_name):
		cls.add_user_signal(signal_name)
	return Signal(cls, signal_name)
