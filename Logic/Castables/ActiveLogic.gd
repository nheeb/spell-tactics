class_name ActiveLogic extends CastableLogic

var active: Active

func _init(_active: Active):
	active = _active
	combat = active.combat
	if active.type.logic != self.get_script():
		push_error("Weird creation of SpellLogic Object")

func get_castable() -> Castable:
	return active

func after_cast():
	super.after_cast()
	if active.is_limited_per_round():
		active.add_to_uses_left(-1)
		
func _on_select_deselect(select: bool) -> void:
	var text_button: TextureButton = active.button.button  # TODO active/not button visuals
	text_button.button_pressed = select


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
#func casting_effect() -> void:
	#pass
