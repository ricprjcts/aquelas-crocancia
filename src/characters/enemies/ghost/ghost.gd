extends BaseEnemy

@export var bt_player: BTPlayer
@export var anim: AnimationPlayer
@export var wall_ray: RayCast2D
@export var ledge_ray: RayCast2D

@export var spawn_time: float = 0.7
@export var damage_stun := 0.05

var blackboard: Blackboard
var player: Player = null
var dead := false

func init() -> void:
	player = MainGame.current.player
	
	blackboard = bt_player.blackboard
	blackboard.set_var("state", "patrol")
	
	health_component.set_invincibility(spawn_time)
	movement_component.set_stun(spawn_time)

func _process(delta: float) -> void:
	if dead:
		return
	
	_flip_char()
	
	if is_player_near():
		if blackboard.get_var("chase_cooldown"):
			return
		
		if blackboard.get_var("state") == "chase":
			return
		
		blackboard.set_var("player", player)
		blackboard.set_var("state", "chase")
		bt_player.restart()

func _physics_process(delta: float) -> void:
	if dead:
		return
	
	_flip_collisions()
	
	velocity.y += movement_component.gravity * delta
	
	move_and_slide()

func stop() -> void:
	if not movement_component.is_stunned():
		velocity.x = 0.0

func move(direction: float) -> void:
	if not movement_component.is_stunned():
		movement_component.direction = direction
		velocity.x = direction * movement_component.speed

func is_player_near() -> bool:
	if player == null:
		return false
	
	return global_position.distance_to(player.global_position) <= 100.0

func is_at_ledge_or_wall() -> bool:
	return wall_ray.is_colliding() or not ledge_ray.is_colliding()

func _on_damage_taken(amount: int) -> void:
	movement_component.set_stun(damage_stun)
	sprite_controller.blink()

func _on_died() -> void:
	bt_player.active = false
	dead = true
	
	hitbox_controller.disable_hitbox(hitbox.collision)
	hitbox_controller.disable_hitbox(hurtbox.collision)
	
	sprite_controller.blink()
	
	movement_component.set_stun()
	
	anim.play("vanish")
	
	await anim.animation_finished
	
	queue_free()

func _flip_char() -> void:
	if sprite and can_flip:
		if movement_component.direction < 0.0:
			sprite.flip_h = false
			facing_right = false
		if movement_component.direction > 0.0:
			sprite.flip_h = true
			facing_right = true

func _flip_collisions() -> void:
	wall_ray.target_position.x = 16.0 if facing_right else -16.0
	ledge_ray.position.x = 12.0 if facing_right else -12.0
