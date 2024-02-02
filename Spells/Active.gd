class_name Active extends Spell

signal got_locked
signal got_unlocked

# FIXME should this go into Spell round specific properties?
var unlocked: bool = false:
	set(u):
		if not u:
			got_locked.emit()
		else:
			got_unlocked.emit()
		unlocked = u
		round_persistant_properties["unlocked"] = u
