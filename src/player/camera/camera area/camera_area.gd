extends Area2D
class_name CameraArea

@export var room_camera: RoomCamera

var _player_camera: PlayerCamera = null

func _ready() -> void:
	_set_collisions()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is not Player:
		return
	
	if _player_camera == null:
		_player_camera = PlayerCamera.current
	
	_player_camera.set_new_camera(room_camera)

func _on_body_exited(body: Node2D) -> void:
	if body is not Player:
		return
	
	if _player_camera == null:
		_player_camera = PlayerCamera.current
	
	_player_camera.set_original_camera()

func _set_collisions() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_mask_value(2, true)
