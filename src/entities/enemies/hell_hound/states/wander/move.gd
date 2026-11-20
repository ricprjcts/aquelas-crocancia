extends HState

@export var idle: HState
@export var jump: HState
@export var fall: HState

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0

@export_range(0.0, 1.0, 0.05) var jump_chance: float = 0.5

var was_on_wall := false

func enter() -> void:
	super()

	if body.is_at_wall():
		was_on_wall = true
		movement.direction = -signf(body.wall_ray.target_position.x)
	else:
		movement.direction = [-1.0, 1.0].pick_random()
	
	if body.is_at_ledge() and body.is_ledge_deep():
		_check_jump()
		return
	
	if body.can_jump_over_wall():
		_check_jump()
		return
	
	wait_time = randf_range(min_wait_time, max_wait_time)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(_on_timer_timeout)

func exit() -> void:
	was_on_wall = false
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, movement.direction * movement.speed, movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

	if body.is_at_wall():
		if not was_on_wall:
			switch_state.emit(idle)
			return

	elif not body.is_at_wall():
		was_on_wall = false
	
	if not body.is_on_floor():
		switch_state.emit(fall)
		return
	
	if body.is_at_ledge() and body.is_ledge_deep():
		switch_state.emit(idle)
		return

func _check_jump() -> void:
	if randf() < jump_chance:
		switch_state.emit(jump)
	else:
		switch_state.emit(idle)

func _on_timer_timeout() -> void:
	if parent_state.active_state == self:
		switch_state.emit(idle)
