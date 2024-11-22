## Class where any parts of the game can register to block tile hovering/clicking.
## Or any other event that could be blocked from different parts.
## For example for UI nodes that cover the 3D World.
class_name Block
var name: String
var blocker_states: Array[bool]  = []
var debug_this: bool

func _init(_name: String = "Block", _debug_this := false):
	name = _name
	debug_this = _debug_this

func register_blocker() -> Blocker: 
	blocker_states.append(false)
	return Blocker.new(len(blocker_states) - 1, self, debug_this)
	
func is_blocked() -> bool:
	return blocker_states.any(func(b: bool): return b)


class Blocker:
	var _idx: int
	var _block: Block
	var _debug_this: bool = false
	
	
	func _init(idx: int, block_instance: Block, debug_this := false) -> void:
		_idx = idx
		_block = block_instance
		_debug_this = debug_this
		
	func block():
		if _debug_this:
			print("%s_%d: blocked" % [_block.name, _idx])
		_block.blocker_states[_idx] = true
		
	func unblock():
		if _debug_this:
			print("%s_%d: unblocked" % [_block.name, _idx])
		_block.blocker_states[_idx] = false
