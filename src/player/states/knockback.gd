extends BaseState

@export var knockback_deceleration: float = 800.0
var knockback_duration: float = 0.0

func enter() -> void:
	var timer := get_tree().create_timer(knockback_duration)
	timer.timeout.connect(_on_knockback_ended)
	
	player.was_on_knockback = false

func exit() -> void:
	player.was_on_knockback = true

func physics_process(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, player.velocity.x, knockback_deceleration * delta)
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if player.do_dash():
		change_state.emit(states[player.states.dash])
		return
	
	if player.do_attack():
		change_state.emit(states[player.states.attack])
		return
	
	if player.can_wall_grab():
		change_state.emit(states[player.states.wall])
		return

func _on_knockback_ended() -> void:
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
