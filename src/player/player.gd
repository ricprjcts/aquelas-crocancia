extends CharacterBody2D
class_name Player

@export_group("Components")
@export var state_machine: StateMachine
@export var input: InputComponent
@export var movement: MovementComponent
@export var health: HealthComponent
@export var knockback: KnockbackComponent

@export_group("Collisions")
@export var collision: CollisionShape2D
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox
@export var wall_ray: RayCast2D
@export var ground_ray: RayCast2D

@export_group("Controllers")
@export var sprite_controller: SpriteController
@export var hitbox_controller: HitboxController

@export_group("Dash")
@export var dash_duration := 0.3
@export var dash_gravity := 0.0
@export var dash_cooldown := 0.5
@export var max_dash_amount: int = 2
var dash_debounce := false
var dash_amount := 1
var dashing := false

@export_group("Attack")
@export var attack_damage := 1
@export var last_attack_damage := attack_damage + 1
@export var attack_cooldown := 0.5
@export var attack_knockback: Vector2 = Vector2(500.0, 0.0)
var attack_debounce := false
var attacking := false

@export_subgroup("Combo")
@export var max_combo: int = 1
@export var max_combo_cooldown: float = 0.5
@export var combo_time: float = 1.0
var current_combo := 0
var can_combo := false

@export_group("Stun")
@export var damage_stun := 0.5
@export var transition_stun_time := 1.0

@export_group("Flash Settings")

@export_subgroup("Death")
@export var death_flash_count: int = 10
@export var death_flash_duration: float = 0.2
@export var death_decay_rate: float = 0.5
@export var death_ease_type: Tween.EaseType = Tween.EaseType.EASE_OUT

@export_subgroup("IFrames")
@export var iframes_flash_count: int = 3
@export var iframes_flash_duration: float = 0.08
@export var iframes_decay_rate: float = 0.5
@export var iframes_ease_type: Tween.EaseType

@onready var sprite: AnimatedSprite2D = $Sprite

var states := {
	idle = "Idle",
	move = "Move",
	jump = "Jump",
	fall = "Fall",
	dash = "Dash",
	attack = "Attack",
	wall = "Wall",
	stun = "Stun",
	knockback = "Knockback",
	dead = "Dead",
	transition = "Transition",
}

var facing_right := true
var can_flip := true
var was_on_knockback := false

var dash := false
var attack := false
var wall_jump = false
var interact := false

var _main_game: MainGame = null
var _jump_buffer := 0.15
var _jump_buffer_counter := 0.0

#region Callbacks
func _ready() -> void:
	_main_game = MainGame.current
	_main_game.screen_fade_out()
	
	_set_health()
	knockback.took_knockback.connect(_on_knockback)
	
	state_machine.init(self, movement)
	
	PlayerHelper.player_ready.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			print("Mouse Click")

func _process(delta: float) -> void:
	input.update()
	
	if not movement.is_stunned() and not health.dead:
		_update_input()
		_flip_char()
		_set_anim()
	
	state_machine.process(delta)

func _physics_process(delta: float) -> void:
	_flip_collisions()
	
	_check_jump_buffer(delta)
	reset_values()
	
	state_machine.physics_process(delta)
#endregion

#region Public Methods
func scene_transition() -> void:
	state_machine.change_state(state_machine.get_node(states.transition))
	hitbox_controller.disable_hitbox(hurtbox.collision)

func wants_wall_jump() -> bool:
	return is_on_wall_only() and movement.jump

func do_wall_jump(duration: float) -> void:
	if wall_jump:
		return
	
	wall_jump = true
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		wall_jump = false
		)

func do_dash() -> bool:
	return dash and can_dash()

func can_dash() -> bool:
	return not dash_debounce and dash_amount > 0 and not attacking and not movement.is_stunned()

func reset_values() -> void:
	if is_on_floor() or is_on_wall_only():
		dash_amount = max_dash_amount
		was_on_knockback = false

func start_dash_cooldown(duration: float = dash_cooldown) -> void:
	dash_debounce = true
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): dash_debounce = false)

func do_attack() -> bool:
	return attack and can_attack()

func can_attack() -> bool:
	return not attack_debounce and not dashing and not movement.is_stunned()

func start_attack_cooldown(duration: float = attack_cooldown) -> void:
	attack_debounce = true
	
	var timer = get_tree().create_timer(duration)
	timer.timeout.connect(func(): attack_debounce = false)

func is_interacting() -> bool:
	return interact and can_interact()

func is_facing_right() -> bool:
	return facing_right

func can_interact() -> bool:
	return is_on_floor() and not movement.is_stunned() and not dashing and not attacking

func can_wall_grab() -> bool:
	return is_on_wall_only() and wall_ray.is_colliding() and not ground_ray.is_colliding() and not movement.is_stunned()

func set_stun(duration: float) -> void:
	var stun_state := state_machine.get_node(states.stun) as BaseState
	stun_state.stun_time = duration
	state_machine.change_state(stun_state)
#endregion

#region Signals
func _set_health() -> void:
	health.health_changed.connect(_on_health_changed)
	health.took_damage.connect(_on_damage_taken)
	health.died.connect(_on_died)
	health.invincibility_started.connect(_on_invincibility_started)
	health.invincibility_ended.connect(_on_invincibility_ended)
	
	PlayerHelper.max_health = health.max_health
	PlayerHelper.health = health.health

func _on_health_changed(current_health: int, max_health: int) -> void:
	PlayerHelper.health_changed.emit(current_health, max_health)

func _on_damage_taken(amount: int) -> void:
	PlayerHelper.took_damage.emit(amount)
	health.set_invincibility(hurtbox.iframes_duration)
	set_stun(damage_stun)
	sprite_controller.flash(iframes_flash_count, iframes_flash_duration, iframes_decay_rate, iframes_ease_type)
	
	sprite.play("hurt")

func _on_died() -> void:
	PlayerHelper.died.emit()
	hitbox_controller.disable_hitbox(hurtbox.collision)
	sprite_controller.flash(death_flash_count, death_flash_duration, death_decay_rate, death_ease_type)
	state_machine.change_state(state_machine.get_node(states.dead))
	
	sprite.play("death")
	await sprite.animation_finished
	get_tree().reload_current_scene()

func _on_invincibility_started() -> void:
	pass

func _on_invincibility_ended():
	if state_machine.active_state.name == states.transition:
		return
	hitbox_controller.reset_hitbox(hurtbox.collision)

func _on_knockback(duration: float) -> void:
	var knockback_state := state_machine.get_node_or_null(states.knockback)
	if knockback_state == null:
		return
	
	knockback_state.knockback_duration = duration
	state_machine.change_state(knockback_state)
#endregion

#region Private Methods
func _update_input() -> void:
	movement.direction = input.direction
	movement.jump = input.jump_pressed
	movement.fall = input.jump_released
	
	dash = input.dash_pressed
	attack = input.attack_pressed
	interact = input.interact_pressed

func _check_jump_buffer(delta: float) -> void:
	if not is_on_floor() and movement.jump:
		_jump_buffer_counter = _jump_buffer
	else:
		_jump_buffer_counter -= delta
	
	if is_on_floor() and _jump_buffer_counter > 0.0:
		_jump_buffer_counter = 0.0
		state_machine.change_state(state_machine.get_node(states.jump))

func _set_anim() -> void:
	match state_machine.active_state.name:
		states.idle:
			sprite.play("idle")
		states.move:
			sprite.play("run")
		states.jump:
			sprite.play("jump")
		states.fall:
			sprite.play("fall")
		states.attack:
			sprite.play("attack_" + str(current_combo))
		states.dash:
			sprite.play("dash")
		states.wall:
			sprite.play("wall")
		states.knockback:
				sprite.play("fall")
		states.transition:
			if is_on_floor():
				sprite.play("run")
			else:
				sprite.play("fall")

func _flip_char() -> void:
	if sprite and can_flip:
		if movement.direction > 0.0:
			sprite.flip_h = false
			facing_right = true
		if movement.direction < 0.0:
			sprite.flip_h = true
			facing_right = false

func _flip_collisions() -> void:
	wall_ray.target_position.x = 16.0 if is_facing_right() else -16.0
	hitbox.collision.position.x = 17.0 if is_facing_right() else -17.0
#endregion
