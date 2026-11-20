extends Enemy

@export var anim: AnimationPlayer
@export var wall_ray: RayCast2D
@export var ledge_ray: RayCast2D

@export_group("States")
@export var wander: HState
@export var attack: HState
@export var damage: HState

func _ready() -> void:
	super()

	health.set_invincibility(spawn_time)
	movement.set_stun(spawn_time)

	anim.play("spawn")

	await anim.animation_finished

	force_change_state(wander)

func _process(delta: float) -> void:
	if health.dead or movement.is_stunned():
		return

	_flip_char()

	if is_player_near() and state_machine.active_state == wander and not attack.attack_debounce and not attack.attacking:
		state_machine.change_state(attack)

	state_machine.process(delta)

func _physics_process(delta: float) -> void:
	if health.dead:
		return

	_flip_collisions()

	state_machine.physics_process(delta)

func is_at_ledge_or_wall() -> bool:
	return wall_ray.is_colliding() or not ledge_ray.is_colliding()

func _on_damage_taken(amount: int) -> void:
	if state_machine.active_state != damage:
		force_change_state(damage)

	health.set_invincibility(hurtbox.damage_iframes_duration)
	movement.set_stun(hurtbox.damage_stun)
	sprite_controller.blink()

func _on_died() -> void:
	hitbox_controller.disable_hitbox(hitbox.collision)
	hitbox_controller.disable_hitbox(hurtbox.collision)

	sprite_controller.blink()

	movement.set_stun()

	anim.play("vanish")

	await anim.animation_finished

	queue_free()

func _set_anim() -> void:
	match state_machine.active_state.name:
		"Idle":
			anim.play("idle")
		"Move":
			anim.play("chase")
		"Chase":
			anim.play("Chase")

func _flip_collisions() -> void:
	wall_ray.target_position.x = 16.0 if facing_right else -16.0
	ledge_ray.position.x = 12.0 if facing_right else -12.0
