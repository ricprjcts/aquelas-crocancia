extends BaseState

func physics_process(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, movement.deceleration * delta)
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if movement.is_moving():
		change_state.emit(states[player.states.move])
		return
	
	if movement.wants_jump():
		change_state.emit(states[player.states.jump])
		return
	
	if player.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if player.do_attack():
		change_state.emit(states[player.states.attack])
		return
	
	if not player.is_on_floor():
		change_state.emit(states[player.states.fall])
		return
