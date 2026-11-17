extends StaticBody2D
class_name Door

@export var collision: CollisionShape2D

func _ready() -> void:
	_set_collision()

func _set_collision() -> void:
	set_collision_mask_value(1, false)
