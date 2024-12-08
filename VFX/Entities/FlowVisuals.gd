class_name FlowVisuals extends VisualEntity

func on_death_visuals():
	hide()

## For overriding and making the drain effect
func visual_drain(drained := true):
	on_death_visuals()  # visuals should wholly disappear on drain

func set_energy_type(energy_type: EnergyStack.EnergyType):
	if has_node("%EnergyOrb"):
		%EnergyOrb.type = energy_type
	if has_node("%EnergyOrb2"):
		%EnergyOrb2.type = energy_type
