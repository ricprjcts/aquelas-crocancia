extends Node
class_name HitboxController

func is_disabled(hitbox: CollisionShape2D) -> bool:
	return hitbox.disabled

func enable_hitbox(hitbox: CollisionShape2D) -> void:
	hitbox.set_deferred("disabled", false)

func disable_hitbox(hitbox: CollisionShape2D) -> void:
	hitbox.set_deferred("disabled", true)

func reset_hitbox(hitbox: CollisionShape2D) -> void:
	hitbox.set_deferred("disabled", true)
	await get_tree().physics_frame
	hitbox.set_deferred("disabled", false)
