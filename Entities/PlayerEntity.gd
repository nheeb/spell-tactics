class_name PlayerEntity extends HPEntity

var secret_msg = "serialize me"

var prop := -1

var arch_enemy : EntityReference


# TODO test if this gets properly serialized
# it does not
var traits := PlayerTraits.new()
