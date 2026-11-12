extends BaseState

var stun_time := 0.0

func enter() -> void:
	var timer := get_tree().create_timer(stun_time)
	timer.timeout.connect(_on_stun_ended)
	
	movement.set_stun(stun_time)
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()

func _on_stun_ended() -> void:
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
