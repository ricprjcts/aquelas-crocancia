extends Area2D
class_name Hurtbox

@export var body: Node2D
@export var collision: CollisionShape2D

@export var health_component: HealthComponent
@export var invincibility_time: float = 1.0

func _ready() -> void:
	_set_collision()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is Hitbox:
		var hitbox = area as Hitbox
		if _cancel_damage(hitbox):
			return
		
		health_component.take_damage(hitbox.damage)
		health_component.set_invincibility(invincibility_time)
		_apply_knockback(hitbox.body.global_position, hitbox.knockback_force)

func _apply_knockback(souce_position: Vector2, force: Vector2) -> void:
	body.velocity.x = force.x if body.global_position > souce_position else -force.x
	body.velocity.y = force.y

func _cancel_damage(hitbox: Hitbox) -> bool:
	return body == hitbox.body or health_component.get_invincibility() or (body is BaseEnemy and hitbox.body is BaseEnemy)

func _set_collision() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_layer_value(4, true)
	set_collision_mask_value(3, true)
