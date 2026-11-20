extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var hitbox: Hitbox
@export var hitbox_controller: HitboxController
@export var knockback: KnockbackComponent

@export var last_attack_duration: float = 0.5
@export var last_attack_delay: float = 0.2
@export var last_attack_cooldown: float = 0.5
@export var last_atack_dash_velocity: float = 100.0
@export var last_attack_deceleration: float = 5.0
@export var last_attack_knockback: Vector2 = Vector2(500.0, 0.0)

@export_group("Self Knockback")
@export var self_knockback: Vector2 = Vector2(100.0, -50.0)
@export var knockback_duration: float = 0.5

var _halfway: bool = false

func enter() -> void:
	super()
	
	if not hitbox.area_entered.is_connected(_on_body_hitbox_area_entered):
		hitbox.area_entered.connect(_on_body_hitbox_area_entered)
	
	hitbox.damage = body.attack_damage
	hitbox.knockback_force = last_attack_knockback
	
	var timer := get_tree().create_timer(last_attack_duration)
	timer.timeout.connect(_on_attack_ended)
	
	var delay_timer := get_tree().create_timer(last_attack_delay)
	delay_timer.timeout.connect(_on_attack_delay_ended)
	
	body.attacking = true
	body.health.set_invincibility(last_attack_duration)

func exit() -> void:
	super()
	
	parent_state.can_combo = false
	body.attacking = false
	body.can_flip = true
	
	if hitbox.area_entered.is_connected(_on_body_hitbox_area_entered):
		hitbox.area_entered.disconnect(_on_body_hitbox_area_entered)
	
	hitbox_controller.disable_hitbox(hitbox.collision)
	_halfway = false

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, last_attack_deceleration * delta)
	if _halfway:
		body.velocity.y += movement.gravity * delta
	else:
		body.velocity.y = move_toward(body.velocity.y, 0.0, movement.deceleration * delta)
	
	super(delta)

func _on_attack_delay_ended() -> void:
	if parent_state.active_state == self:
		body.start_attack_cooldown(last_attack_cooldown)
		body.velocity.x = last_atack_dash_velocity if body.facing_right else -last_atack_dash_velocity
		body.can_flip = false
		hitbox_controller.enable_hitbox(hitbox.collision)
		_halfway = true

func _on_body_hitbox_area_entered(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	
	var hurtbox := area as Hurtbox
	if hurtbox.body == body:
		return
	
	knockback.apply_knockback(hurtbox.global_position, self_knockback, knockback_duration)

func _on_attack_ended() -> void:
	if parent_state.active_state == self:
		if body.is_on_floor():
			if movement.is_moving():
				parent_state.switch_state.emit(move)
			else:
				parent_state.switch_state.emit(idle)
		else:
			parent_state.switch_state.emit(fall)
