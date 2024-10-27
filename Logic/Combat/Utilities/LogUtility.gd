class_name LogUtility extends CombatUtility

var log_entries: Array[LogEntry] = []

signal log_entry_registered(entry: LogEntry)

func register_entry(entry: LogEntry) -> void:
	if combat:
		entry.round_number = combat.current_round
		entry.round_phase = combat.current_phase
	log_entries.append(entry)
	log_entry_registered.emit(entry)

func filtered_entries(flavor: ActionFlavor = ActionFlavor.new(), \
			min_round := 0, max_round := combat.current_round) -> Array[LogEntry]:
	var round_filter := log_entries.filter(
		func (le: LogEntry):
			return le.round_number >= min_round and le.round_number <= max_round
	)
	var flavor_filter := round_filter.filter(
		func (le: LogEntry):
			return flavor.fits_into(le.flavor, combat)
	)
	return flavor_filter

func add(text: String, print_this := false):
	var info = LogEntry.new(text)
	info.type = LogEntry.Type.Info
	register_entry(info)
	if print_this:
		print("Combat Log Info: %s" % text)
