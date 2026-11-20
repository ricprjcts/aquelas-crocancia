@icon("res://icons/node2d/human.svg")

extends CharacterBody2D
class_name CharacterEntity

@export var state_machine: HStateMachine
@export var sprite: CanvasItem
@export_enum("Left", "Right") var start_direction: String = "Right"

@export_group("Components")
@export var movement: MovementComponent
@export var health: HealthComponent
@export var knockback: KnockbackComponent

@export_group("Collisions")
@export var collision: CollisionShape2D
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox

@export_group("Controllers")
@export var sprite_controller: SpriteController
@export var hitbox_controller: HitboxController

var start_right: bool
var facing_right: bool = true
var can_flip: bool = true

var _main_game: MainGame = null

func _ready() -> void:
	_main_game = MainGame.current
	
	start_right = start_direction == "Right"
	facing_right = start_right
	
	health.health_changed.connect(_on_health_changed)
	health.took_damage.connect(_on_damage_taken)
	health.died.connect(_on_died)
	health.invincibility_started.connect(_on_invincibility_started)
	health.invincibility_ended.connect(_on_invincibility_ended)
	
	knockback.took_knockback.connect(_on_knockback)
	
	state_machine.init(self, movement)

func force_change_state(new_state: HState) -> void:
	if state_machine.active_state == new_state:
		return
	
	state_machine.change_state(new_state)

func is_facing_right() -> bool:
	return facing_right

func take_damage(data: HitData) -> void:
	if health.invincibility:
		return
	
	if data.damage == 0 or data.knockback_force == Vector2.ZERO or data.knockback_duration == 0.0:
		return
	
	health.take_damage(data.damage)
	knockback.apply_knockback(data.attacker_position, data.knockback_force, data.knockback_duration)

func _on_health_changed(current_health: int, max_health: int) -> void:
	pass

func _on_damage_taken(amount: int) -> void:
	pass

func _on_died() -> void:
	pass

func _on_invincibility_started() -> void:
	pass

func _on_invincibility_ended():
	pass

func _on_knockback(duration: float) -> void:
	pass

func _flip_char() -> void:
	if sprite and can_flip:
		if movement.direction > 0.0:
			sprite.flip_h = false if start_right else true
			facing_right = true
		if movement.direction < 0.0:
			sprite.flip_h = true if start_right else false
			facing_right = false

func _flip_collisions() -> void:
	pass
