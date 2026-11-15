extends BTAction

@export var min_stop_duration: float = 1.0
@export var max_stop_duration: float = 5.0

var stop_duration: float = 0.0
var stop_timer: float = 0.0

func _enter() -> void:
	stop_duration = randf_range(min_stop_duration, max_stop_duration)

func _exit() -> void:
	stop_timer = 0.0

func _tick(delta: float) -> Status:
	agent.stop()
	
	stop_timer += delta
	if stop_timer >= stop_duration:
		return SUCCESS
	
	return RUNNING
