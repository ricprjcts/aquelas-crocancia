extends BaseState

func physics_process(delta: float) -> void:
	var friction := movement.acceleration if movement.is_moving() else movement.deceleration
	if not movement.is_moving() and player.was_on_knockback:
		player.velocity.x = move_toward(player.velocity.x, player.velocity.x, friction * delta)
	else:
		player.velocity.x = move_toward(player.velocity.x, movement.direction * movement.speed, friction * delta)
	
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if player.is_on_floor():
		_touch_floor()
		return
	
	if player.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if player.do_attack():
		change_state.emit(states[player.states.attack])
		return
	
	if player.can_wall_grab():
		change_state.emit(states[player.states.wall])
		return

func _touch_floor() -> void:
	if not movement.is_moving():
		change_state.emit(states[player.states.idle])
	else:
		change_state.emit(states[player.states.move])
