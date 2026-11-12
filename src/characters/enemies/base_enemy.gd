extends CharacterBody2D
class_name BaseEnemy

@export_group("Components")
@export var health_component: HealthComponent
@export var movement_component: MovementComponent

@export_group("Collisions")
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox

@export_group("Controllers")
@export var sprite_controller: SpriteController
@export var hitbox_controller: HitboxController

var spawner: EntitySpawner = null

func _ready() -> void:
	health_component.took_damage.connect(_on_damage_taken)
	health_component.died.connect(_on_died)
	init()

func init() -> void:
	pass

func _on_damage_taken(amount: int) -> void:
	pass

func _on_died() -> void:
	pass
