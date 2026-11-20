@icon("res://icons/node/heart.svg")

extends Component
class_name HealthComponent

signal health_changed(current: int, max: int)
signal took_damage(amount: int)
signal died

signal invincibility_started
signal invincibility_ended

@export var max_health := 5
var health := 0 :
	set(new_health):
		health = new_health
		health_changed.emit(health, max_health)
	get():
		return health

var dead := false :
	set(value):
		dead = value
		died.emit()
	get():
		return dead

var invincibility := false

func _ready() -> void:
	health = max_health

func take_damage(amount: int) -> void:
	var new_health := clampi(health - amount, 0, max_health)
	health = new_health
	
	if health <= 0:
		dead = true
		return
	
	took_damage.emit(amount)

func set_invincibility(duration: float) -> void:
	if invincibility:
		return
	
	invincibility = true
	invincibility_started.emit()
	
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		invincibility = false
		invincibility_ended.emit()
		)
