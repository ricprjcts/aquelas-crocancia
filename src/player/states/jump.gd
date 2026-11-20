extends HState

@export var fall: HState
@export var dash: HState
@export var attack: HState

func enter() -> void:
	super()
	
	body.velocity.y = movement.jump_velocity

func physics_process(delta: float) -> void:
	if not body.wall_jump:
		var target := movement.direction * movement.speed if movement.is_moving() else 0.0
		var friction := movement.acceleration if movement.is_moving() else movement.deceleration
		body.velocity.x = move_toward(body.velocity.x, target, friction * delta)
	
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.velocity.y > 10.0:
		switch_state.emit(fall)
		return
	
	if body.do_dash():
		switch_state.emit(dash)
		return
	
	if body.do_attack():
		switch_state.emit(attack)
		return
	
	if movement.fall:
		body.velocity.y = 0.0
		switch_state.emit(fall)
		return
