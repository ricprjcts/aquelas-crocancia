extends BaseEnemy


func _on_damage_taken(amount: int) -> void:
	sprite_controller.blink()

func _on_died() -> void:
	sprite_controller.blink()
	await get_tree().create_timer(0.5).timeout
	queue_free()
