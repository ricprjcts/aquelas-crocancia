extends BaseState

@export var deceleration: float = 5.0

func enter() -> void:
	movement.stunned = true
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, deceleration * delta)
	player.velocity.y += movement.gravity * delta
	player.move_and_slide()
