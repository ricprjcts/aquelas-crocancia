extends HState

@export var idle: HState
@export var jump: HState
@export var fall: HState
@export var dash: HState
@export var attack: HState

@export var coyote_jump := 0.2
var coyote_jump_counter := 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, movement.direction * movement.speed, movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.do_dash():
		switch_state.emit(dash)
		return
	
	if body.do_attack():
		switch_state.emit(attack)
		return
	
	if not body.is_on_floor():
		_check_coyote_jump(delta)
		return
	
	if not movement.is_moving():
		switch_state.emit(idle)
		return
	
	if movement.wants_jump():
		switch_state.emit(jump)
		return

func _check_coyote_jump(delta: float) -> void:
	coyote_jump_counter += delta
	if movement.jump and coyote_jump_counter < coyote_jump:
		coyote_jump_counter = 0.0
		switch_state.emit(jump)
	else:
		coyote_jump_counter = 0.0
		switch_state.emit(fall)
