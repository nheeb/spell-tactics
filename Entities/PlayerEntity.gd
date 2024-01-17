class_name PlayerEntity extends HPEntity

var secret_msg = "serialize me"

var prop := -1

class Traits extends Resource:
	@export var max_handsize: int = 5
	@export var movement_range: int = 3


# TODO test if this gets properly serialized
var traits := Traits.new()
