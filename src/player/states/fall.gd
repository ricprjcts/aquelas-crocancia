extends HState

@export var idle: HState
@export var move: HState
@export var dash: HState
@export var attack: HState
@export var wall: HState

var was_on_knockback: bool

func physics_process(delta: float) -> void:
	was_on_knockback = body.was_on_knockback as bool
	
	var friction := movement.acceleration if movement.is_moving() else movement.deceleration
	if not movement.is_moving() and was_on_knockback:
		body.velocity.x = move_toward(body.velocity.x, body.velocity.x, friction * delta)
	else:
		body.velocity.x = move_toward(body.velocity.x, movement.direction * movement.speed, friction * delta)
	
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.is_on_floor():
		_touch_floor()
		return
	
	if body.do_dash():
		switch_state.emit(dash)
		return
	
	if body.do_attack():
		switch_state.emit(attack)
		return
	
	if body.can_wall_grab():
		switch_state.emit(wall)
		return

func _touch_floor() -> void:
	if movement.is_moving():
		switch_state.emit(move)
	else:
		switch_state.emit(idle)
