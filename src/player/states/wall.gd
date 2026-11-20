extends HState

@export var idle: HState
@export var move: HState
@export var jump: HState
@export var fall: HState

@export var wall_stick_force := 20.0
@export var wall_gravity := 0.25
@export var max_wall_gravity := 0.5
var wall_gravity_multi := 0.0

@export var wall_jump_velocity := 100.0
@export var leave_wall_delay := 0.5
@export var wall_jump_duration := 0.2
var leave_wall_timer := 0.0

@export var sprite_offset := 1.0

func enter() -> void:
	super()
	
	body.sprite.offset.x = -sprite_offset if body.is_facing_right() else sprite_offset
	
	body.velocity = Vector2.ZERO
	body.can_flip = false
	
	wall_gravity_multi = wall_gravity

func exit() -> void:
	body.sprite.offset.x = 0.0
	body.can_flip = true
	
	leave_wall_timer = 0.0

func physics_process(delta: float) -> void:
	var wall_dir := signf(body.wall_ray.target_position.x)
	
	body.velocity.x = wall_dir * wall_stick_force
	body.velocity.y += (movement.gravity * wall_gravity_multi) * delta
	body.move_and_slide()
	
	wall_gravity_multi = minf(wall_gravity_multi + (wall_gravity_multi * delta), max_wall_gravity)
	
	if not body.wall_ray.is_colliding() or body.is_on_floor():
		_leave_wall_default()
		return
	
	if body.wants_wall_jump():
		_wall_jump()
		return
	
	if movement.is_moving():
		_leave_wall(delta)
	else:
		leave_wall_timer = 0.0

func _leave_wall_default() -> void:
	if body.is_on_floor():
		if movement.is_moving():
			switch_state.emit(move)
		else:
			switch_state.emit(idle)
	else:
		switch_state.emit(fall)

func _leave_wall(delta: float) -> void:
	if movement.direction == -signf(body.wall_ray.target_position.x):
		leave_wall_timer += delta
		if leave_wall_timer >= leave_wall_delay:
			if body.is_on_floor():
				if movement.is_moving():
					switch_state.emit(move)
				else:
					switch_state.emit(idle)
			else:
				switch_state.emit(fall)
	else:
		leave_wall_timer = 0.0

func _wall_jump() -> void:
	body.velocity.x = -wall_jump_velocity if body.is_facing_right() else wall_jump_velocity
	body.velocity.y = movement.jump_velocity
	body.do_wall_jump(wall_jump_duration)
	switch_state.emit(jump)
