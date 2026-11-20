extends RefCounted
class_name HitData

var damage: int
var attacker_position: Vector2
var knockback_force: Vector2
var knockback_duration: float

func _init(_damage: int, _attacker_position: Vector2,_knockback_force: Vector2, _knockback_duration: float) -> void:
	damage = _damage
	attacker_position = _attacker_position
	knockback_force = _knockback_force
	knockback_duration = _knockback_duration
