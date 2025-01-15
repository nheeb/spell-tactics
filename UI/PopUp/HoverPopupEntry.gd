class_name HoverPopupEntry extends MarginContainer

@onready var icons = [%EnergyIcon1, %EnergyIcon2, %EnergyIcon3, %EnergyIcon4]


func show_drainable_entity(ent: Entity):
	$VBoxContainer/HoverEnergyList.show()
	$VBoxContainer/StatusEffectList.hide()  # maybe later these might also have status effects
	%EntityName.text = ent.type.pretty_name
	var n_energies := 0
	if ent.energy != null:
		n_energies = len(ent.energy.stack)
	
	icons.map(func (i): i.hide	())
	
	for i in range(n_energies):
		var icon = icons[i]
		icon.show()
		icon.type = ent.energy.stack[i]
		
func show_player_entity(ent: PlayerEntity):
	%EntityName.text = ent.type.pretty_name
	$VBoxContainer/Flavor.show()
	$VBoxContainer/Flavor.text = ent.type.fluff_text
	$VBoxContainer/HoverEnergyList.hide()
	$VBoxContainer/StatusEffectList.hide()
	

const STATUS_ICON = preload("res://UI/PopUp/HoverStatusEffectIcon.tscn")
func show_enemy_entity(ent: EnemyEntity):
	$VBoxContainer/HoverEnergyList.hide()
	$%EntityName.text = ent.get_name()
	for effect: EntityStatus in ent.status_array:
		var type: EntityStatusType = effect.type
		print(type.internal_name)
		var status_icon = STATUS_ICON.instantiate()
		$VBoxContainer/StatusEffectList.add_child(status_icon)
		status_icon.get_node("ColorRect").material.set_shader_parameter("icon_mask", type.icon)
		
		
