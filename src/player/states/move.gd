extends BaseState

@export var coyote_jump := 0.2
var coyote_jump_counter := 0.0

func physics_process(delta: float) -> void:
	player.velocity.x = movement.direction * movement.speed
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if not movement.is_moving():
		change_state.emit(states[player.states.idle])
		return
	
	if movement.wants_jump():
		change_state.emit(states[player.states.jump])
		return
	
	if movement.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if movement.do_attack():
		change_state.emit(states[player.states.attack])
		return
	
	if not player.is_on_floor():
		_check_coyote_jump(delta)
		return

func _check_coyote_jump(delta: float) -> void:
	coyote_jump_counter += delta
	if movement.jump and coyote_jump_counter < coyote_jump:
		coyote_jump_counter = 0.0
		change_state.emit(states[player.states.jump])
	elif coyote_jump_counter >= coyote_jump:
		coyote_jump_counter = 0.0
		change_state.emit(states[player.states.fall])
