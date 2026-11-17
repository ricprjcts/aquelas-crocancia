extends BaseEnemy

@export_group("Behavior Tree")
@export var bt_player: BTPlayer
@export var enabled: bool = true

@export_group("Components")
@export var anim: AnimationPlayer

@export_group("Collisions")
@export var wall_ray: RayCast2D
@export var ledge_ray: RayCast2D

@export_group("Values")
@export var spawn_time: float = 0.7
@export var damage_stun := 0.05

var blackboard: Blackboard
var player: Player = null

func init() -> void:
	player = MainGame.current.player
	
	blackboard = bt_player.blackboard
	blackboard.set_var("stunned", true)
	blackboard.set_var("state", "patrol")
	
	if spawn_time != 0.0:
		health.set_invincibility(spawn_time)
		movement.set_stun(spawn_time)

func _process(delta: float) -> void:
	bt_player.active = enabled
	blackboard.set_var("stunned", movement.is_stunned())
	
	if health.dead or movement.is_stunned() or not bt_player.active:
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
	if health.dead:
		return
	
	if not enabled:
		if not movement.is_stunned():
			velocity.x = 0.0
			velocity.y += movement.gravity * delta
			move_and_slide()
	
	_flip_collisions()
	
	velocity.y += movement.gravity * delta
	
	move_and_slide()

func stop() -> void:
	if not movement.is_stunned():
		velocity.x = 0.0

func move(direction: float) -> void:
	if not movement.is_stunned():
		movement.direction = direction
		velocity.x = direction * movement.speed

func is_player_near() -> bool:
	if player == null:
		return false
	
	return global_position.distance_to(player.global_position) <= 100.0

func is_at_ledge_or_wall() -> bool:
	return wall_ray.is_colliding() or not ledge_ray.is_colliding()

func _on_damage_taken(amount: int) -> void:
	movement.set_stun(damage_stun)
	sprite_controller.blink()

func _on_died() -> void:
	bt_player.active = false
	
	hitbox_controller.disable_hitbox(hitbox.collision)
	hitbox_controller.disable_hitbox(hurtbox.collision)
	
	sprite_controller.blink()
	
	movement.set_stun()
	
	anim.play("vanish")
	
	await anim.animation_finished
	
	queue_free()

func _flip_char() -> void:
	if sprite and can_flip:
		if movement.direction < 0.0:
			sprite.flip_h = false
			facing_right = false
		if movement.direction > 0.0:
			sprite.flip_h = true
			facing_right = true

func _flip_collisions() -> void:
	wall_ray.target_position.x = 16.0 if facing_right else -16.0
	ledge_ray.position.x = 12.0 if facing_right else -12.0
