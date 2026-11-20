extends HState

@export var move: HState

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0

func enter() -> void:
	super()

	wait_time = randf_range(min_wait_time, max_wait_time)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(_on_timer_timeout)

	movement.direction = 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, movement.deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

func _on_timer_timeout() -> void:
	if parent_state.active_state == self:
		if randf() < 0.5:
			switch_state.emit(move)
		else:
			switch_state.emit(self)
