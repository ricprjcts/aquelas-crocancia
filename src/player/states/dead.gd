extends HState

@export var deceleration: float = 5.0

func enter() -> void:
	super()
	
	movement.stunned = true
	movement.direction = 0.0

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
