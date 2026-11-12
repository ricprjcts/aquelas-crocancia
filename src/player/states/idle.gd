extends BaseState

func physics_process(delta: float) -> void:
	player.velocity.x = 0.0
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if movement.is_moving():
		change_state.emit(states[player.states.move])
	
	if movement.wants_jump():
		change_state.emit(states[player.states.jump])
	
	if movement.do_dash():
		change_state.emit(states[player.states.dash])
	
	if movement.do_attack():
		change_state.emit(states[player.states.attack])
	
	if not player.is_on_floor():
		change_state.emit(states[player.states.fall])
