extends HState

@export var land: HState

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, movement.direction * movement.speed, movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.is_on_floor():
		switch_state.emit(land)
		return
