class_name ActiveLogic extends CastableLogic

var active: Active:
	get:
		return combat_object as Active
	set(x):
		push_error("Do not set this.")

func get_castable() -> Castable:
	return active

func after_cast():
	super.after_cast()
	if active.is_limited_per_round():
		active.add_to_uses_left(-1)
		
func on_select_deselect(select: bool) -> void:
	var text_button: TextureButton = active.button.button  # TODO active/not button visuals
	combat.animation.property(text_button, "button_pressed", select)


#####################################
## For overriding in each Castable ##
#####################################

### This is for overriding if there are general cast-conditions
#func _is_unlocked() -> bool:
	#return true

### This is for overriding if there are conditions for targets
#func is_current_cast_valid() -> bool:
	#return true
#
### Most important function for overwriting. Here should be the effect
#func execute() -> void:
	#pass
