extends Area2D
class_name Hurtbox

@export var body: Node2D
@export var collision: CollisionShape2D

@export var knockback_component: KnockbackComponent
@export var health_component: HealthComponent
@export var iframes_duration: float = 1.0

func _ready() -> void:
	_set_collision()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		if _cancel_damage(hitbox):
			return
		
		health_component.take_damage(hitbox.damage)
		knockback_component.apply_knockback(hitbox.body.global_position, hitbox.knockback_force, hitbox.knockback_duration)

func _cancel_damage(hitbox: Hitbox) -> bool:
	return body == hitbox.body or health_component.invincibility or (body is BaseEnemy and hitbox.body is BaseEnemy)

func _set_collision() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true)
