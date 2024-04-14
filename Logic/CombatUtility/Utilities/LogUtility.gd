class_name LogUtility extends CombatUtility

var log_entries: Array[LogEntry] = []

func register_entry(entry: LogEntry) -> void:
	log_entries.append(entry)

func entries_filtered_by_type(type: LogEntry.Type):
	return log_entries.filter(func(x): return x.type == type)

func add(text: String, print_this := true):
	var info = LogEntry.new()
	info.type = LogEntry.Type.Info
	info.text = text
	if combat:
		info.round_number = combat.current_round
	register_entry(info)
	if print_this:
		print("Combat Log Info: %s" % text)

func register_incident(text: String, print_this := false):
	var incident = LogEntry.new()
	incident.type = LogEntry.Type.Incident
	incident.text = text
	if combat:
		incident.round_number = combat.current_round
	register_entry(incident)
	if print_this:
		print("Combat Log Incident: %s" % text)

func get_last_incident(text: String) -> LogEntry:
	var incidents := log_entries.filter(func (entry): \
					return entry.type == LogEntry.Type.Incident and entry.text == text)
	if incidents:
		return incidents[-1]
	return null

func create_and_register_entry(text: String, type: int) -> LogEntry:
	var entry = LogEntry.new()
	entry.type = type
	entry.text = text
	if combat:
		entry.round_number = combat.current_round
	register_entry(entry)
	return entry

func get_current_round() -> int:
	var filtered = log_entries.filter(func (x): return x.type != LogEntry.Type.EventPrognose)
	if filtered.is_empty():
		return 1
	else:
		return filtered[-1].round_number
