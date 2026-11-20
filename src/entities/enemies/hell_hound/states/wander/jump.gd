extends HState

@export var fall: HState

@export var speed_multiplier: float = 1.5
var speed: float

func enter() -> void:
	super()
	
	body.velocity.y = movement.jump_velocity
	movement.direction = signf(body.wall_ray.target_position.x)
	
	speed = movement.speed * speed_multiplier if body.is_ledge_deep() else movement.speed

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, movement.direction * speed, movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.velocity.y > 10.0:
		switch_state.emit(fall)
		return
