class_name ActionFlavor extends RefCounted
## An object to describe an ActionTicket. Used to hook onto certain Actions.

## Enum describing possible types of Actions
enum Action {
	Damage,
	Attack,
	Cast,
	PA
}

## Ideally the source of the action
var owner: Object
## Description of the action using enum values
var actions: Array[Action]
## Targets of the action
var targets: Array[Object]
## Whatever else could be relevant
var bonus: Array

func set_owner(_owner: Object) -> ActionFlavor:
	owner = _owner
	return self

func add_action(action: Action) -> ActionFlavor:
	actions.append(action)
	return self

func add_target(target: Object) -> ActionFlavor:
	targets.append(target)
	return self

func add_bonus(x) -> ActionFlavor:
	bonus.append(x)
	return self

## Returns true if this flavor agrees with the other one while possibly being less detailed.
## An empty flavor fits into every other flavor.
func fits_into(action_flavor: ActionFlavor) -> bool:
	return  (owner == null or owner == action_flavor.owner) \
		and (actions.all(func (x): return x in action_flavor.actions)) \
		and (targets.all(func (x): return x in action_flavor.targets)) \
		and   (bonus.all(func (x): return x in action_flavor.bonus))

## Returns true if the other flavor fits into this one. See fits_into()
func can_fit(fitting_flavor: ActionFlavor) -> bool:
	return fitting_flavor.fits_into(self)
