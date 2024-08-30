extends Control

var entry: LogEntry
@onready var label: FixedLabel = %FixedLabel

func setup(_entry: LogEntry):
	entry = _entry
	label.set_text_fixed(LogEntry.entry_to_string(entry))
