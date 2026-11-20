extends Enemy

@export var wall_ray: RayCast2D
@export var high_wall_ray: RayCast2D
@export var ledge_ray: RayCast2D
@export var deep_ledge_ray: RayCast2D

@export var wander: HState
@export var idle: HState
@export var move: HState
@export var jump: HState
@export var fall: HState

@export var pursuit: HState

func _process(delta: float) -> void:
	if health.dead or movement.is_stunned():
		return
	
	_flip_char()
	
	if is_player_near() and state_machine.active_state != pursuit:
		force_change_state(pursuit)
		return
	
	state_machine.process(delta)

func _physics_process(delta: float) -> void:
	if health.dead:
		return
	
	_flip_collisions()
	
	state_machine.physics_process(delta)

func is_at_ledge() -> bool:
	return not ledge_ray.is_colliding()

func is_ledge_deep() -> bool:
	return not deep_ledge_ray.is_colliding()

func is_at_wall() -> bool:
	return wall_ray.is_colliding()

func can_jump_over_wall() -> bool:
	return wall_ray.is_colliding() and not high_wall_ray.is_colliding()

func _on_damage_taken(amount: int) -> void:
	health.set_invincibility(hurtbox.damage_iframes_duration)
	sprite_controller.blink()

func _on_died() -> void:
	sprite_controller.blink()
	
	await get_tree().create_timer(0.5).timeout
	
	queue_free()

func _flip_collisions() -> void:
	wall_ray.target_position.x = 26.0 if is_facing_right() else -26.0
	ledge_ray.position.x = 13.0 if is_facing_right() else -13.0
	
	high_wall_ray.target_position.x = wall_ray.target_position.x
	deep_ledge_ray.position.x = ledge_ray.position.x
