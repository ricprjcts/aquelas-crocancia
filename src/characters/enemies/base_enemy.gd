extends CharacterBody2D
class_name BaseEnemy

@export_group("Components")
@export var sprite: Sprite2D
@export var health: HealthComponent
@export var movement: MovementComponent

@export_group("Collisions")
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox

@export_group("Controllers")
@export var sprite_controller: SpriteController
@export var hitbox_controller: HitboxController

var facing_right := false
var can_flip := true

func _ready() -> void:
	health.took_damage.connect(_on_damage_taken)
	health.died.connect(_on_died)
	init()

func init() -> void:
	pass

func _on_damage_taken(amount: int) -> void:
	pass

func _on_died() -> void:
	pass
