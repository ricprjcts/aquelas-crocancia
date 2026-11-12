extends BaseState

func enter() -> void:
	movement.stunned = true
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, movement.speed * 0.015)
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
