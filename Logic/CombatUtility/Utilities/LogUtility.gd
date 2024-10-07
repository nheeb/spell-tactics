class_name LogUtility extends CombatUtility

var log_entries: Array[LogEntry] = []

signal log_entry_registered(entry: LogEntry)
signal cast(castable: Castable)

signal logged_damage(entry: LogEntry)

func register_entry(entry: LogEntry) -> void:
	log_entries.append(entry)
	log_entry_registered.emit(entry)

func entries_filtered_by_type(type: LogEntry.Type):
	return log_entries.filter(func(x): return x.type == type)

func add(text: String, print_this := false):
	var info = LogEntry.new(combat)
	info.type = LogEntry.Type.Info
	info.text = text
	if combat:
		info.round_number = combat.current_round
	register_entry(info)
	if print_this:
		print("Combat Log Info: %s" % text)

func register_incident(text: String, print_this := false):
	var incident = LogEntry.new(combat)
	incident.type = LogEntry.Type.Incident
	incident.text = text
	if combat:
		incident.round_number = combat.current_round
	register_entry(incident)
	if print_this:
		print("Combat Log Incident: %s" % text)

func register_cast(castable: Castable):
	var entry := LogEntry.new(combat)
	entry.type = LogEntry.Type.Cast
	entry.uni_ref = castable.get_reference_castable()
	if combat:
		entry.round_number = combat.current_round
	cast.emit(castable)
	register_entry(entry)

func get_last_incident(text: String) -> LogEntry:
	var incidents := log_entries.filter(func (entry): \
					return entry.type == LogEntry.Type.Incident and entry.text == text)
	if incidents:
		return incidents[-1]
	return null

func create_and_register_entry(text: String, type: int) -> LogEntry:
	var entry = LogEntry.new(combat)
	entry.type = type
	entry.text = text
	if combat:
		entry.round_number = combat.current_round
	register_entry(entry)
	return entry
