class_name ActionFlavor extends Resource
## An object to describe an ActionTicket. Used to hook onto certain Actions.

## Enum describing possible types of Actions
enum Action {
	Damage,
	Attack,
	Cast,
	PA,
	Melee,
	Movement,
}

## Ideally the source of the action
@export var owner: UniversalReference
## Description of the action using enum values
@export var actions: Array[Action]
## Targets of the action
@export var targets: Array[UniversalReference]
## Whatever else could be relevant. Only serializable stuff!
@export var bonus: Array

func set_owner(_owner) -> ActionFlavor:
	owner = UniversalReference.from(_owner)
	return self

func add_action(action: Action) -> ActionFlavor:
	actions.append(action)
	return self

func add_target(target) -> ActionFlavor:
	targets.append(UniversalReference.from(target))
	return self

func add_bonus(x) -> ActionFlavor:
	bonus.append(x)
	return self

func dereferenced_array(array: Array, combat: Combat) -> Array:
	var deref := []
	for x in array:
		if x is UniversalReference:
			deref.append(x.resolve(combat))
		else:
			deref.append(x)
	return deref

## Returns true if this flavor agrees with the other one while possibly being less detailed.
## An empty flavor fits into every other flavor.
func fits_into(action_flavor: ActionFlavor, combat: Combat) -> bool:
	if action_flavor == null:
		return false
	# TODO Cache this stuff maybe
	var own_actions := dereferenced_array(actions, combat)
	var own_targets := dereferenced_array(targets, combat)
	var own_bonus := dereferenced_array(bonus, combat)
	var other_actions := dereferenced_array(action_flavor.actions, combat)
	var other_targets := dereferenced_array(action_flavor.targets, combat)
	var other_bonus := dereferenced_array(action_flavor.bonus, combat)
	return  (owner == null or owner.resolve(combat) == action_flavor.owner.resolve(combat)) \
		and (own_actions.all(func (x): return x in other_actions)) \
		and (own_targets.all(func (x): return x in other_targets)) \
		and   (own_bonus.all(func (x): return x in other_bonus))

## Returns true if the other flavor fits into this one. See fits_into()
func can_fit(fitting_flavor: ActionFlavor, combat: Combat) -> bool:
	if fitting_flavor == null:
		return true
	return fitting_flavor.fits_into(self, combat)
