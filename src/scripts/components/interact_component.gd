extends Area2D
class_name InteractComponent

signal interact_enabled(player: Player)
signal interact_disabled

func _ready() -> void:
	_set_collision()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	var player := body as Player
	interact_enabled.emit(player)

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	interact_disabled.emit()

func _set_collision() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_mask_value(2, true)
