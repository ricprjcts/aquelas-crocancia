extends HState

@export var move: HState
@export var jump: HState
@export var fall: HState

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0

@export_range(0.0, 1.0, 0.05) var jump_chance: float = 0.5

func enter() -> void:
	super()

	movement.direction = 0.0
	
	wait_time = randf_range(min_wait_time, max_wait_time)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(_on_timer_timeout)

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, movement.deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if not body.is_on_floor():
		switch_state.emit(fall)
		return

func _on_timer_timeout() -> void:
	if parent_state.active_state == self:
		if randf() < 0.5:
			switch_state.emit(move)
		else:
			switch_state.emit(self)
