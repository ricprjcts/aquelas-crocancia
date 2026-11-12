extends BaseState

@export var hitbox: Hitbox
@export var hitbox_controller: HitboxController

func enter() -> void:
	var timer := get_tree().create_timer(movement.attack_duration)
	timer.timeout.connect(_on_attack_ended)
	
	movement.attacking = true
	player.can_flip = false
	hitbox_controller.enable_hitbox(hitbox.collision)

func physics_process(delta: float) -> void:
	player.velocity.x = movement.direction * movement.speed
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
	
	if movement.fall and player.velocity.y < 0.0:
		player.velocity.y = 0.0

func _on_attack_ended() -> void:
	movement.attacking = false
	player.can_flip = true
	
	movement.start_attack_cooldown()
	hitbox_controller.disable_hitbox(hitbox.collision)
	
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
