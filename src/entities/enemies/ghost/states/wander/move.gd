extends HState

@export var idle: HState

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0

var was_on_wall := false

func enter() -> void:
	super()

	wait_time = randf_range(min_wait_time, max_wait_time)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(_on_timer_timeout)

	if body.is_at_ledge_or_wall():
		was_on_wall = true
		movement.direction = -signf(body.wall_ray.target_position.x)
	else:
		movement.direction = [-1.0, 1.0].pick_random()

func exit() -> void:
	was_on_wall = false
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, movement.direction * movement.speed, movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

	if body.is_at_ledge_or_wall() and not was_on_wall:
		switch_state.emit(idle)
		return

	elif not body.is_at_ledge_or_wall():
		was_on_wall = false

func _on_timer_timeout() -> void:
	if parent_state.active_state == self:
		switch_state.emit(idle)
