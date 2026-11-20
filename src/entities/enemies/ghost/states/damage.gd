extends HState

@export var wander: HState

@export var stun_deceleration: float = 3000

func enter() -> void:
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, stun_deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

	if not movement.is_stunned():
		switch_state.emit(wander)
		return
