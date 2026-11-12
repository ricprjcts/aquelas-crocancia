extends CharacterBody2D
class_name Player

@export_group("Components")
@export var state_machine: StateMachine
@export var input: InputComponent
@export var health: HealthComponent
@export var movement: PlayerMovement

@export_group("Collisions")
@export var collision: CollisionShape2D
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox

@export_group("Controllers")
@export var sprite_controller: SpriteController
@export var hitbox_controller: HitboxController

@export_category("Values")
@export var damage_iframes := 1.0
@export var damage_stun := 0.5
@export var transition_stun_time := 1.0

@onready var sprite: AnimatedSprite2D = $Sprite

@onready var _wall_ray: RayCast2D = $Raycasts/WallRay
@onready var _ground_ray: RayCast2D = $Raycasts/GroundRay

var states := {
	idle = "Idle",
	move = "Move",
	jump = "Jump",
	fall = "Fall",
	dash = "Dash",
	attack = "Attack",
	wall = "Wall",
	stun = "Stun",
	dead = "Dead",
	transition = "Transition",
}
var facing_right := true
var can_flip := true
var interact := false

var _jump_buffer := 0.15
var _jump_buffer_counter := 0.0

#region Callbacks
func _ready() -> void:
	_set_health()
	
	MainGame.current.scene_loaded.connect(_on_level_loaded)
	PlayerHelper.player_ready.emit()
	state_machine.init(self, movement)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			print("Mouse Click")

func _process(delta: float) -> void:
	input.update()
	
	_flip_char()
	_set_anim()
	
	if not movement.is_stunned():
		_update_input()
	
	state_machine.process(delta)

func _physics_process(delta: float) -> void:
	_flip_collisions()
	
	movement.update_dash_amount()
	_check_jump_buffer(delta)
	
	state_machine.physics_process(delta)
#endregion

#region Public Methods
func scene_transition() -> void:
	state_machine.change_state(state_machine.get_node(states.transition))
	hitbox_controller.disable_hitbox(hurtbox.collision)

func is_interacting() -> bool:
	return _can_interact()

func is_facing_right() -> bool:
	return facing_right

func _can_interact() -> bool:
	return interact and is_on_floor() and not movement.is_stunned() and not movement.dashing and not movement.attacking

func can_wall_grab() -> bool:
	return is_on_wall_only() and _wall_ray.is_colliding() and not _ground_ray.is_colliding()

func set_stun(duration: float) -> void:
	var stun_state := state_machine.get_node(states.stun) as BaseState
	stun_state.stun_time = duration
	state_machine.change_state(stun_state)
#endregion

#region Health Related
func _set_health() -> void:
	health.took_damage.connect(_on_damage_taken)
	health.died.connect(_on_died)
	health.invincibility_started.connect(_on_invincibility_started)
	health.invincibility_ended.connect(_on_invincibility_ended)
	health.health_changed.connect(_on_health_changed)
	PlayerHelper.max_health = health.max_health
	PlayerHelper.health = health.get_health()

func _on_health_changed(current_health: int, max_health: int) -> void:
	PlayerHelper.health_changed.emit(current_health, max_health)

func _on_damage_taken(amount: int) -> void:
	PlayerHelper.took_damage.emit(amount)
	health.set_invincibility(damage_iframes)
	set_stun(damage_stun)
	sprite_controller.blink()
	
	sprite.play("hurt")

func _on_died() -> void:
	PlayerHelper.died.emit()
	hitbox_controller.disable_hitbox(hurtbox.collision)
	set_stun(damage_stun)
	movement.dead = true
	sprite_controller.blink()
	state_machine.change_state(state_machine.get_node(states.dead))
	
	sprite.play("death")
	await sprite.animation_finished
	get_tree().reload_current_scene()

func _on_invincibility_started() -> void:
	pass

func _on_invincibility_ended():
	hitbox_controller.reset_hitbox(hurtbox.collision)
#endregion

func _on_level_loaded() -> void:
	pass

func _update_input() -> void:
	movement.direction = input.direction
	movement.jump = input.jump_pressed
	movement.fall = input.jump_released
	movement.dash = input.dash_pressed
	movement.attack = input.attack_pressed
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
			sprite.play("attack")
		states.dash:
			sprite.play("dash")
		states.wall:
			sprite.play("wall")
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
	_wall_ray.target_position.x = 16.0 if is_facing_right() else -16.0
	hitbox.collision.position.x = 17.0 if is_facing_right() else -17.0
