@icon("res://icons/node2d/keyboard.svg")
extends CharacterEntity
class_name Player

@export_group("States")
@export var jump_state: HState
@export var dash_state: HState
@export var attack_state: HState
@export var stun_state: HState
@export var knockback_state: HState
@export var dead_state: HState
@export var transition_state: HState

@export_group("Components")
@export var input: InputComponent

@export_group("Collisions")
@export var wall_ray: RayCast2D
@export var ground_ray: RayCast2D

@export_group("Dash")
@export var dash_cooldown: float = 0.5
@export var max_dash_amount: int = 2
var dash_debounce: bool = false
var dash_amount: int = 1
var dashing: bool = false

@export_group("Attack")
@export var attack_damage: int = 1
@export var last_attack_damage: int = attack_damage + 1
@export var attack_cooldown: float = 0.5
@export var attack_knockback: Vector2 = Vector2(500.0, 0.0)
var attack_debounce: bool = false
var attacking: bool = false

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

var was_on_knockback := false

var dash := false
var attack := false
var wall_jump = false
var interact := false

var _input_buffer: float = 0.2
var _jump_buffer: float = 0.0
var _attack_buffer: float = 0.0
var _dash_buffer: float = 0.0

#region Callbacks
func _ready() -> void:
	super()
	
	_main_game.screen_fade_out()
	
	PlayerHelper.max_health = health.max_health
	PlayerHelper.health = health.health
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
	
	state_machine.process(delta)

func _physics_process(delta: float) -> void:
	_flip_collisions()
	
	_check_jump_buffer(delta)
	_check_dash_buffer(delta)
	_check_attack_buffer(delta)
	reset_values()
	
	state_machine.physics_process(delta)
#endregion

#region Public Methods
func scene_transition() -> void:
	state_machine.change_state(transition_state)
	hitbox_controller.disable_hitbox(hurtbox.collision)

func reset_values() -> void:
	if is_on_floor() or is_on_wall_only():
		dash_amount = max_dash_amount
		was_on_knockback = false

func do_dash() -> bool:
	return dash and can_dash()

func can_dash() -> bool:
	return not dash_debounce and dash_amount > 0 and not attacking and not movement.is_stunned()

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

func can_interact() -> bool:
	return is_on_floor() and not movement.is_stunned() and not dashing and not attacking

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

func can_wall_grab() -> bool:
	return is_on_wall_only() and wall_ray.is_colliding() and not ground_ray.is_colliding() and not movement.is_stunned()
#endregion

#region Private Methods
func _on_health_changed(current_health: int, max_health: int) -> void:
	PlayerHelper.health_changed.emit(current_health, max_health)

func _on_damage_taken(amount: int) -> void:
	PlayerHelper.took_damage.emit(amount)
	
	stun_state.stun_time = hurtbox.damage_stun
	force_change_state(stun_state)
	
	health.set_invincibility(hurtbox.damage_iframes_duration)
	
	sprite_controller.flash(iframes_flash_count, iframes_flash_duration, iframes_decay_rate, iframes_ease_type)
	
	sprite.play("hurt")

func _on_died() -> void:
	PlayerHelper.died.emit()
	
	hitbox_controller.disable_hitbox(hurtbox.collision)
	sprite_controller.flash(death_flash_count, death_flash_duration, death_decay_rate, death_ease_type)
	
	force_change_state(dead_state)
	
	sprite.play("death")
	
	await sprite.animation_finished
	
	get_tree().reload_current_scene()

func _on_invincibility_started() -> void:
	pass

func _on_invincibility_ended():
	if state_machine.active_state == transition_state:
		return
	hitbox_controller.reset_hitbox(hurtbox.collision)

func _on_knockback(duration: float) -> void:
	knockback_state.knockback_duration = duration
	force_change_state(knockback_state)

func _update_input() -> void:
	movement.direction = input.direction
	movement.jump = input.jump_pressed
	movement.fall = input.jump_released
	
	dash = input.dash_pressed
	attack = input.attack_pressed
	interact = input.interact_pressed

func _check_jump_buffer(delta: float) -> void:
	if movement.jump:
		_jump_buffer = _input_buffer
	else:
		_jump_buffer -= delta
	
	if _jump_buffer > 0.0 and is_on_floor() and not movement.is_stunned() and not attacking and not dashing:
		_jump_buffer = 0.0
		force_change_state(jump_state)

func _check_dash_buffer(delta: float) -> void:
	if dash:
		_dash_buffer = _input_buffer
	else:
		_dash_buffer -= delta
	
	if _dash_buffer > 0.0 and can_dash():
		_dash_buffer = 0.0
		force_change_state(dash_state)

func _check_attack_buffer(delta: float) -> void:
	if attack:
		_attack_buffer = _input_buffer
	else:
		_attack_buffer -= delta
	
	if _attack_buffer > 0.0 and can_attack():
		_attack_buffer = 0.0
		force_change_state(attack_state)

func _flip_collisions() -> void:
	wall_ray.target_position.x = 16.0 if is_facing_right() else -16.0
	hitbox.collision.position.x = 13.5 if is_facing_right() else -13.5
#endregion
