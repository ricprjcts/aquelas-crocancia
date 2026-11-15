extends BaseState

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
	wall_gravity_multi = wall_gravity
	
	player.sprite.offset.x = -sprite_offset if player.is_facing_right() else sprite_offset
	
	player.velocity = Vector2.ZERO
	player.can_flip = false

func exit() -> void:
	player.sprite.offset.x = 0.0
	player.can_flip = true
	
	leave_wall_timer = 0.0

func physics_process(delta: float) -> void:
	var wall_dir := signf(player.wall_ray.target_position.x)
	
	player.velocity.x = wall_dir * wall_stick_force
	player.velocity.y += (movement.gravity * wall_gravity_multi) * delta
	player.move_and_slide()
	
	wall_gravity_multi = minf(wall_gravity_multi + (wall_gravity_multi * delta), max_wall_gravity)
	
	if not player.wall_ray.is_colliding() or player.is_on_floor():
		_leave_wall_default()
		return
	
	if movement.wants_wall_jump():
		_wall_jump()
		return
	
	if movement.is_moving():
		_leave_wall(delta)
	else:
		leave_wall_timer = 0.0

func _leave_wall_default() -> void:
	if player.is_on_floor():
		if movement.is_moving():
			change_state.emit(states[player.states.move])
		else:
			change_state.emit(states[player.states.idle])
	else:
		change_state.emit(states[player.states.fall])

func _leave_wall(delta: float) -> void:
	if movement.direction == -signf(player.wall_ray.target_position.x):
		leave_wall_timer += delta
		if leave_wall_timer >= leave_wall_delay:
			if player.is_on_floor():
				if movement.is_moving():
					change_state.emit(states[player.states.move])
				else:
					change_state.emit(states[player.states.idle])
			else:
				change_state.emit(states[player.states.fall])
	else:
		leave_wall_timer = 0.0

func _wall_jump() -> void:
	player.velocity.x = -wall_jump_velocity if player.is_facing_right() else wall_jump_velocity
	player.velocity.y = movement.jump_velocity
	movement.do_wall_jump(wall_jump_duration)
	change_state.emit(states[player.states.jump])
