class_name WaitTicket extends Object

signal resolved

func resolve():
	resolved.emit()

func resolve_on(s: Signal):
	s.connect(resolve, CONNECT_ONE_SHOT)
