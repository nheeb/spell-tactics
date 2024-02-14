class_name CoinPickupOption extends Object

var coin_amount: int

@warning_ignore("shadowed_variable")
func _init(coin_amount: int):
	self.coin_amount = coin_amount

func apply() -> bool:
	Adventure.add_coins(coin_amount)
	return true
