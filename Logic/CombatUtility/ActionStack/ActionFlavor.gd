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
	EnemyAction,
	EnemyEvent,
	CombatEvent
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

## If finalized, all the references have been resolved and cached.
## The flavor shouldn't be edited further.
var finalized := false
var _owner: Object
var _targets: Array
var _data: Dictionary

func set_owner(_owner) -> ActionFlavor:
	owner = UniversalReference.from(_owner)
	return self

func add_tag(tag: Tag) -> ActionFlavor:
	tags.append(tag)
	return self

func add_target(target) -> ActionFlavor:
	targets.append(UniversalReference.from(target))
	return self

func add_data(key, x) -> ActionFlavor:
	var array: Array = data.get_or_add(key, [])
	array.append(x)
	return self

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

func integrate(other_flavor: ActionFlavor) -> ActionFlavor:
	return self
