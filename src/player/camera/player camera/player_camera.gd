extends Camera2D
class_name PlayerCamera

static var current: PlayerCamera = null

@export_group("Look Ahead")
@export var look_ahead_offset: float = 4.0
@export var look_ahead_speed: float = 10.0

@export_group("Catch Player")
@export var catch_player_speed: float = 10.0
@export var catch_player_threshold: float = 10.0
@export var catch_player_time := 1.0

@export_group("Vectors")
@export var follow_offset: Vector2

@export_category("Tween")
@export var tween_resource: TweenResource

var base_zoom: Vector2

var base_limit_left: int
var base_limit_top: int
var base_limit_right: int
var base_limit_bottom: int

var _switching_camera := false
var _on_room_camera := false
var _room_camera_follow := false
var _room_camera_axis_lock := "None"

var _catch_player_counter := 0.0

var _player: Player = null

func _ready() -> void:
	set_process(false)
	
	base_zoom = zoom
	base_limit_left = limit_left
	base_limit_top = limit_top
	base_limit_right = limit_right
	base_limit_bottom = limit_bottom

func _process(delta: float) -> void:
	if _on_room_camera:
		if _room_camera_follow and _room_camera_axis_lock != "None":
			match _room_camera_axis_lock:
				"X":
					drag_vertical_enabled = false
				"Y":
					drag_vertical_enabled = true
			_follow_player()
			return
		
		drag_vertical_enabled = false
		return
	
	if _switching_camera:
		_catch_player(delta)
		return
	
	_catch_player_counter = 0.0
	
	_follow_player()
	_look_ahead(delta)

func init(player: Player) -> void:
	current = self
	_player = player
	set_process(true)

func disable() -> void:
	set_process(false)
	current = null
	_player = null
	
	_catch_player_counter = 0.0
	_switching_camera = false
	_on_room_camera = false
	_room_camera_follow = false
	_room_camera_axis_lock = "None"

func set_new_camera(new_camera: RoomCamera):
	if _player == null:
		return
	
	_catch_player_counter = 0.0
	_switching_camera = false
	_on_room_camera = true
	_room_camera_follow = new_camera.follow_enabled
	_room_camera_axis_lock = new_camera.axis_lock
	
	var tween := create_tween()
	
	tween.set_parallel()
	tween.set_ease(new_camera.tween_resource.ease)
	tween.set_trans(new_camera.tween_resource.interpolation)
	tween.tween_property(self, "global_position", new_camera.global_position, new_camera.tween_resource.duration)
	tween.tween_property(self, "offset", new_camera.offset, new_camera.tween_resource.duration)
	tween.tween_property(self, "zoom", new_camera.zoom, new_camera.tween_resource.duration)
	
	limit_left = new_camera.limit_left
	limit_top = new_camera.limit_top
	limit_right = new_camera.limit_right
	limit_bottom = new_camera.limit_bottom

func set_original_camera() -> void:
	if _player == null or SceneManager.transitioning:
		return
	
	_catch_player_counter = 0.0
	
	_switching_camera = true
	_on_room_camera = false
	_room_camera_follow = false
	_room_camera_axis_lock = "None"
	
	var offset_x := look_ahead_offset if _player.is_facing_right() else -look_ahead_offset
	
	var tween := create_tween()
	
	tween.set_parallel()
	tween.set_ease(tween_resource.ease)
	tween.set_trans(tween_resource.interpolation)
	tween.tween_property(self, "zoom", base_zoom, tween_resource.duration)
	tween.tween_property(self, "offset", Vector2(offset_x, follow_offset.y), tween_resource.duration)
	
	limit_left = base_limit_left
	limit_top = base_limit_top
	limit_right = base_limit_right
	limit_bottom = base_limit_bottom

func _catch_player(delta: float) -> void:
	_catch_player_counter += delta
	
	if global_position.distance_squared_to(_player.global_position) <= catch_player_threshold or _catch_player_counter >= catch_player_time:
		_switching_camera = false
		return
	
	global_position = global_position.lerp(_player.global_position, 1.0 - exp(-catch_player_speed * delta))

func _follow_player() -> void:
	if _room_camera_axis_lock != "None":
		match _room_camera_axis_lock:
			"X":
				global_position = Vector2(_player.global_position.x, global_position.y)
			"Y":
				global_position = Vector2(global_position.x, _player.global_position.y)
		return
	
	global_position = _player.global_position

func _look_ahead(delta: float) -> void:
	var weight := 1.0 - exp(-look_ahead_speed * delta)
	if _player.velocity.x == 0.0:
		if _player.is_facing_right():
			offset.x = lerpf(offset.x, look_ahead_offset, weight)
		else:
			offset.x = lerpf(offset.x, -look_ahead_offset, weight)
	else:
		offset.x = lerpf(offset.x, 0.0, weight)
	
	offset.y = lerpf(offset.y, follow_offset.y, weight)
