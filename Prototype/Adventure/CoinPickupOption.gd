class_name CoinPickupOption extends Object

var coin_amount: int

func _init(_coin_amount: int):
	self.coin_amount = _coin_amount

func apply() -> bool:
	Adventure.add_coins(coin_amount)
	return true
