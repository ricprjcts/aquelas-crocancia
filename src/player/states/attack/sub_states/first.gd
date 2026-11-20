extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var combo_timer: Timer
@export var hitbox: Hitbox
@export var hitbox_controller: HitboxController

@export var first_attack_duration: float = 0.3
@export var first_attack_delay: float = 0.0
@export var first_attack_knockback: Vector2 = Vector2(500.0, 0.0)

func enter() -> void:
	super()
	
	body.attacking = true
	body.can_flip = false
	
	hitbox.damage = body.attack_damage
	hitbox.knockback_force = body.attack_knockback
	
	hitbox_controller.enable_hitbox(hitbox.collision)
	
	var timer := get_tree().create_timer(first_attack_duration)
	timer.timeout.connect(_on_attack_ended)

func exit() -> void:
	super()
	
	body.start_attack_cooldown()
	body.attacking = false
	body.can_flip = true
	
	hitbox_controller.disable_hitbox(hitbox.collision)

func physics_process(delta: float) -> void:
	var target := movement.direction * movement.speed if movement.is_moving() else 0.0
	var friction := movement.acceleration if movement.is_moving() else movement.deceleration
	body.velocity.x = move_toward(body.velocity.x, target, friction * delta)
	body.velocity.y += movement.gravity * delta
	
	super(delta)

func _on_attack_ended() -> void:
	if parent_state.active_state == self:
		parent_state.start_combo_timer()
		
		if body.is_on_floor():
			if movement.is_moving():
				parent_state.switch_state.emit(move)
			else:
				parent_state.switch_state.emit(idle)
		else:
			parent_state.switch_state.emit(fall)
