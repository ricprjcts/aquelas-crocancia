extends BaseState

func enter() -> void:
	player.velocity.y = movement.jump_velocity

func physics_process(delta: float) -> void:
	if not player.wall_jump:
		var target := movement.direction * movement.speed if movement.is_moving() else 0.0
		var friction := movement.acceleration if movement.is_moving() else movement.deceleration
		player.velocity.x = move_toward(player.velocity.x, target, friction * delta)
	
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if player.velocity.y > 10.0:
		change_state.emit(states[player.states.fall])
		return
	
	if movement.fall:
		player.velocity.y = 0.0
		change_state.emit(states[player.states.fall])
		return
	
	if player.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if player.do_attack():
		change_state.emit(states[player.states.attack])
		return
