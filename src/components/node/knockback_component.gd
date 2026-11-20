extends Component
class_name KnockbackComponent

signal took_knockback(duration: float)

@export var body: CharacterEntity

func apply_knockback(souce_position: Vector2, force: Vector2, duration: float = 0.5) -> void:
	took_knockback.emit(duration)
	
	body.velocity.x = force.x if body.global_position > souce_position else -force.x
	body.velocity.y = force.y
