class_name ActionFlavor extends Resource
## An object to describe an ActionTicket. Used to hook onto certain Actions.

## Enum describing possible types of Actions
enum Tag {
	Damage,
	Attack,
	Cast,
	PlayerAction,
	Melee,
	Movement,
	EnemyActionGeneric,
	EnemyActionSpecific,
	EnemyEvent,
	CombatEvent,
	Drain,
	Spell,
	Active
}

## Ideally the source of the action
@export var owner: UniversalReference
## Description of the action using enum values
@export var tags: Array[Tag]
## Targets of the action
@export var targets: Array[UniversalReference]
## Whatever else could be relevant. Only serializable stuff!
## All values are Arrays
@export var data: Dictionary

# TBD maybe add negative tags ?

## If finalized, all the references have been resolved and cached.
## The flavor shouldn't be edited further.
var finalized := false
var _owner: Object
var _targets: Array
var _data: Dictionary

## Set the owner or actor of the flavor. In most cases the entity that causes the action.
func set_owner(own) -> ActionFlavor:
	owner = UniversalReference.from(own)
	return self

## Add a tag to describe the action / subaction
func add_tag(tag: Tag) -> ActionFlavor:
	tags.append(tag)
	return self

## Add a target which gets affected by the action
func add_target(target) -> ActionFlavor:
	targets.append(UniversalReference.from(target))
	return self

## Add multiple targets at once
func add_target_array(target_array: Array) -> ActionFlavor:
	for target in target_array:
		add_target(target)
	return self

## Add any important details
func add_data(key, x) -> ActionFlavor:
	if x is Dictionary:
		push_warning("Adding a dict as flavor data might be dangerous.")
	key = UniversalReference.reference_or_value(key)
	var array: Array = data.get_or_add(key, [])
	if x is Array:
		for element in x:
			array.append(UniversalReference.reference_or_value(element))
	else:
		array.append(UniversalReference.reference_or_value(x))
	return self

## Execute this at the end of a flavor creation. This will created cached references.
func finalize(combat: Combat) -> ActionFlavor:
	# Only finalize when not finalized
	if finalized:
		return self
	finalized = true
	# Cache resolved references
	_owner = UniversalReference.dereference(owner, combat)
	_targets = UniversalReference.dereference_array(targets, combat)
	_data = UniversalReference.dereference_dict(data, combat)
	return self

## Returns true if this flavor agrees with the other one while possibly being less detailed.
## An empty flavor fits into every other flavor.
func fits_into(action_flavor: ActionFlavor, combat: Combat) -> bool:
	finalize(combat)
	if action_flavor == null:
		return false
	action_flavor.finalize(combat)
	return  (owner == null or _owner == action_flavor._owner) \
		and (tags.all(func (x): return x in action_flavor.tags)) \
		and (_targets.all(func (x): return x in action_flavor._targets)) \
		and (_data.keys().all(
			func (k):
				var v = _data[k] as Array
				return v.all(
					func (x): return x in action_flavor._data[k]
				))
			)

## Returns true if the other flavor fits into this one. See fits_into()
func can_fit(fitting_flavor: ActionFlavor, combat: Combat) -> bool:
	if fitting_flavor == null:
		return true
	return fitting_flavor.fits_into(self, combat)

func extend_with(other_flavor: ActionFlavor, overwrite_data := false) -> ActionFlavor:
	if owner == null or overwrite_data:
		set_owner(owner)
	for tag in other_flavor.tags:
		add_tag(tag)
	if overwrite_data:
		data.merge(other_flavor.data, true)
	else:
		for key in other_flavor.data.keys():
			add_data(key, other_flavor.data[key])
	return self
