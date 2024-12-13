class_name DrainablePopupEntry extends MarginContainer

@onready var icons = [%EnergyIcon1, %EnergyIcon2, %EnergyIcon3, %EnergyIcon4]

func show_drainable_entity(ent: Entity):
	%EntityName.text = ent.type.pretty_name
	var n_energies := 0
	if ent.energy != null:
		n_energies = len(ent.energy.stack)
	
	icons.map(func (i): i.hide())
	
	for i in range(n_energies):
		var icon = icons[i]
		icon.show()
		icon.type = ent.energy.stack[i]
		
func show_player_entity(ent: PlayerEntity):
	pass
	
	
func show_enemy_entity(ent: EnemyEntity):
	pass
