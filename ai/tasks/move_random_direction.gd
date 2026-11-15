extends BTAction

@export var min_move_duration: float = 1.0
@export var max_move_duration: float = 5.0

var move_duration: float = 0.0
var move_timer: float = 0.0

var direction: float = 0.0

func _enter() -> void:
	move_duration = randf_range(min_move_duration, max_move_duration)
	if agent.is_at_ledge_or_wall():
		direction = -signf(agent.wall_ray.target_position.x)
	else:
		direction = [-1.0, 1.0].pick_random()

func _exit() -> void:
	agent.velocity.x = 0.0
	
	move_timer = 0.0
	direction = 0.0

func _tick(delta: float) -> Status:
	agent.move(direction)
	
	move_timer += delta
	if move_timer >= move_duration:
		return SUCCESS
	
	if agent.is_at_ledge_or_wall():
		return FAILURE
	
	return RUNNING
