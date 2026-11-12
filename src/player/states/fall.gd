extends BaseState

func physics_process(delta: float) -> void:
	player.velocity.x = movement.direction * movement.speed
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if player.is_on_floor():
		if not movement.is_moving():
			change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.move])
	
	if movement.do_dash():
		change_state.emit(states[player.states.dash])
	
	if movement.do_attack():
		change_state.emit(states[player.states.attack])
	
	if player.can_wall_grab():
		change_state.emit(states[player.states.wall])
