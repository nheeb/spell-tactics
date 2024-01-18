extends MarginContainer

@onready var icons = [%EnergyIcon1, %EnergyIcon2, %EnergyIcon3, %EnergyIcon4]

func show_entity(ent: Entity):
	%EntityName.text = ent.type.pretty_name
	var n_energies = len(ent.energy)
	
	icons.map(func (i): i.hide())
	
	for i in range(n_energies):
		var icon = icons[i]
		icon.show()
		icon.type = ent.energy[i]
