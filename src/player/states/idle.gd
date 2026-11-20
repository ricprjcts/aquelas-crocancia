extends HState

@export var move: HState
@export var jump: HState
@export var fall: HState
@export var dash: HState
@export var attack: HState

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, movement.deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.do_dash():
		switch_state.emit(dash)
		return
	
	if body.do_attack():
		switch_state.emit(attack)
		return
	
	if not body.is_on_floor():
		switch_state.emit(fall)
		return
	
	if movement.is_moving():
		switch_state.emit(move)
		return
	
	if movement.wants_jump():
		switch_state.emit(jump)
		return
