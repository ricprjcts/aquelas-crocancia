extends BaseState

func enter() -> void:
	player.velocity.y = movement.jump_velocity

func physics_process(delta: float) -> void:
	if not movement.wall_jump:
		player.velocity.x = movement.direction * movement.speed
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if player.velocity.y > 10.0:
		change_state.emit(states[player.states.fall])
		return
	
	if movement.fall:
		player.velocity.y = 0.0
		change_state.emit(states[player.states.fall])
		return
	
	if movement.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if movement.do_attack():
		change_state.emit(states[player.states.attack])
		return
