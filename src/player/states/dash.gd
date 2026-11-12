extends BaseState

func enter() -> void:
	var timer := get_tree().create_timer(movement.dash_duration)
	timer.timeout.connect(_on_dash_ended)
	
	movement.dashing = true
	movement.dash_amount -= 1
	
	player.can_flip = false
	
	player.velocity.x = movement.dash_velocity if player.is_facing_right() else -movement.dash_velocity

func physics_process(delta: float) -> void:
	player.velocity.y = movement.dash_gravity
	player.move_and_slide()

func _on_dash_ended() -> void:
	movement.dashing = false
	player.can_flip = true
	
	movement.start_dash_cooldown()
	
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
