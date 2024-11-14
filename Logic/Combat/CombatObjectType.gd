class_name CombatObjectType extends Resource

## Name that will be shown ingame (for example when hovering)
@export var pretty_name: String
## Extra text that will maybe be shown ingame (for example when hovering)
@export_multiline var fluff_text: String
## Icon that will be shown ingame
@export var icon: Texture
## Associated color
@export var color: Color 
## Default data values the Object should be created with
@export var default_data: Dictionary

var _loaded := false
var internal_name: String
var logic_script: GDScript

func create_base_object() -> CombatObject:
	return null

func create(combat: Combat, props := {}) -> CombatObject:
	# Load script and name
	on_load()
	# Load default data if no data in props
	var data := props.get("data", {}) as Dictionary
	data.merge(default_data, false)
	props["data"] = data
	# Create combat independent base object from type
	var obj := create_base_object()
	assert(obj, "You need to create a base object")
	# Update props if any are given
	obj.update_properties(props)
	# Connect with combat
	obj.connect_with_combat(combat)
	# Create CombatLogic
	if logic_script:
		var logic: CombatLogic = logic_script.new() as CombatLogic
		assert(logic, "CombatLogic wasn't created.")
		logic.setup(obj)
		obj.set("logic", logic)
	# Put on_birth on the stack for special creation effects
	if not obj.born:
		combat.action_stack.push_back(obj.on_birth)
	# Put on_load on the stack for animation related stuff
	combat.action_stack.push_back(obj.on_load)
	return obj

## This connects the Type to it's filename / script file
func on_load() -> void:
	if not _loaded:
		_loaded = true
		internal_name = resource_path.split("/")[-1].split(".")[0]
		var directory = "/".join(resource_path.split("/").slice(0, -1))
		var script_path: String = directory + "/" + internal_name + ".gd"
		if ResourceLoader.exists(script_path):
			logic_script = load(script_path)
		_on_load()

## This method can be overwritten by other Types to do special stuff
func _on_load() -> void:
	pass
