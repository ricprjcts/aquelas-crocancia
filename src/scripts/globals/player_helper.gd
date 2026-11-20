extends Node

signal player_ready

signal health_changed(current_health: int, max_health: int)
signal took_damage(amount: int)
signal died

var max_health: int
var health: int

var money: int = 0 :
	set(value):
		money = value
	get():
		return money
