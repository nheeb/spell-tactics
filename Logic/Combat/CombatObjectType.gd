class_name CombatObjectType extends Resource

## Name that will be shown ingame (for example when hovering)
@export var pretty_name: String
## Extra text that will maybe be shown ingame (for example when hovering)
@export_multiline var fluff_text: String
## Icon that will be shown ingame
@export var icon: Texture

var internal_name: String
var logic_script: Script

func create_base_object() -> CombatObject:
	return null

func create(combat: Combat, props := {}) -> CombatObject:
	var obj := create_base_object()
	obj.update_properties(props)
	obj.connect_with_combat(combat)
	if not obj.born:
		combat.action_stack.push_back(obj.on_birth)
	combat.action_stack.push_back(obj.on_load)
	return obj

## This connects the Type to it's filename / script file
func on_load() -> void:
	if internal_name == "":
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		var script_path: String = directory + "/" + internal_name + ".gd"
		if ResourceLoader.exists(script_path):
			logic_script = load(script_path)
		_on_load()

## This method can be overwritten by other Types to do special stuff
func _on_load() -> void:
	pass
