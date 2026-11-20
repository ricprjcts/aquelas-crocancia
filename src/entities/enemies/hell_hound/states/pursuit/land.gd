extends HState

@export var chase: HState
@export var fall: HState

@export var landing_duration: float = 0.5

func enter() -> void:
	super()
	
	var timer := get_tree().create_timer(landing_duration)
	timer.timeout.connect(_on_landing_ended)

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, movement.deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

func _on_landing_ended() -> void:
	if parent_state.active_state == self:
		if body.is_on_floor():
			switch_state.emit(chase)
		else:
			switch_state.emit(fall)
