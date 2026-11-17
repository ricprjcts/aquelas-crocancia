extends BaseState

@export var dash_velocity := 200.0
@export var dash_deceleration: float = 5.0

func enter() -> void:
	var timer := get_tree().create_timer(player.dash_duration)
	timer.timeout.connect(_on_dash_ended)
	
	player.dashing = true
	player.dash_amount -= 1
	
	player.can_flip = false
	
	player.velocity.x = dash_velocity if player.is_facing_right() else -dash_velocity

func exit() -> void:
	player.start_dash_cooldown()
	player.dashing = false
	player.can_flip = true

func physics_process(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, dash_deceleration * delta)
	player.velocity.y = player.dash_gravity
	player.move_and_slide()

func _on_dash_ended() -> void:
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
