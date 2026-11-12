extends InteractObject



func _on_interact() -> void:
	if _player == null:
		return
	interact_component.queue_free()
	play("open")
	_player.set_stun(1.0)
