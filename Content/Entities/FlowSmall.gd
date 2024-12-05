extends EntityLogic

@export var energy_type: EnergyStack.EnergyType = EnergyStack.EnergyType.Empty

func on_load():
	var vis := entity.visual_entity as FlowVisuals
	if vis:
		vis.set_energy_type(energy_type)

func on_birth():
	# Choose random type
	if energy_type == EnergyStack.EnergyType.Empty:
		energy_type = EnergyStack.random_energy_type()
	entity.energy = EnergyStack.new([energy_type])

func on_interact() -> void:
	combat.energy.gain(entity.energy, entity)
