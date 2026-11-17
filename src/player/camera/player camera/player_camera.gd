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
var _tween: Tween = null

func _ready() -> void:
	set_process(false)
	
	base_zoom = zoom
	base_limit_left = limit_left
	base_limit_top = limit_top
	base_limit_right = limit_right
	base_limit_bottom = limit_bottom

func _process(delta: float) -> void:
	if _player == null:
		return
	
	if _on_room_camera:
		if _room_camera_follow and _room_camera_axis_lock != "None":
			drag_vertical_enabled = _room_camera_axis_lock == "Y"
			if _switching_camera:
				_catch_player(delta)
			else:
				_follow_player()
			return
		
		drag_vertical_enabled = false
		return
	
	if _switching_camera:
		_catch_player(delta)
		return
	
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
	_kill_tween()
	_reset_state()

func set_new_camera(new_camera: RoomCamera) -> void:
	if _player == null:
		return
	
	_on_room_camera = true
	_room_camera_follow = new_camera.follow_enabled
	_room_camera_axis_lock = new_camera.axis_lock
	_catch_player_counter = 0.0
	
	var follows_player := _room_camera_follow and _room_camera_axis_lock != "None"
	_switching_camera = follows_player
	
	var tween := _new_tween(new_camera.tween_resource)
	var duration := new_camera.tween_resource.duration
	
	if not follows_player:
		tween.tween_property(self, "global_position", new_camera.global_position, duration)
	elif _room_camera_axis_lock == "X":
		tween.tween_property(self, "global_position:y", new_camera.global_position.y, duration)
	else:
		tween.tween_property(self, "global_position:x", new_camera.global_position.x, duration)
	
	tween.tween_property(self, "offset", new_camera.offset, duration)
	tween.tween_property(self, "zoom", new_camera.zoom, duration)
	
	limit_left = new_camera.limit_left
	limit_top = new_camera.limit_top
	limit_right = new_camera.limit_right
	limit_bottom = new_camera.limit_bottom

func set_original_camera() -> void:
	if _player == null or SceneManager.transitioning:
		return
	
	_reset_state()
	_switching_camera = true
	
	var offset_x := look_ahead_offset if _player.is_facing_right() else -look_ahead_offset
	
	var tween := _new_tween(tween_resource)
	tween.tween_property(self, "zoom", base_zoom, tween_resource.duration)
	tween.tween_property(self, "offset", Vector2(offset_x, follow_offset.y), tween_resource.duration)
	
	limit_left = base_limit_left
	limit_top = base_limit_top
	limit_right = base_limit_right
	limit_bottom = base_limit_bottom

func _new_tween(resource: TweenResource) -> Tween:
	_kill_tween()
	_tween = create_tween()
	_tween.set_parallel()
	_tween.set_ease(resource.ease)
	_tween.set_trans(resource.interpolation)
	return _tween

func _kill_tween() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = null

func _reset_state() -> void:
	_catch_player_counter = 0.0
	_switching_camera = false
	_on_room_camera = false
	_room_camera_follow = false
	_room_camera_axis_lock = "None"

func _catch_player(delta: float) -> void:
	_catch_player_counter += delta
	
	var weight := 1.0 - exp(-catch_player_speed * delta)
	var target := _player.global_position
	var pos := global_position
	var distance: float
	
	match _room_camera_axis_lock:
		"X":
			pos.x = lerpf(pos.x, target.x, weight)
			distance = absf(pos.x - target.x)
		"Y":
			pos.y = lerpf(pos.y, target.y, weight)
			distance = absf(pos.y - target.y)
		_:
			pos = pos.lerp(target, weight)
			distance = pos.distance_to(target)
	
	global_position = pos
	
	if distance <= catch_player_threshold or _catch_player_counter >= catch_player_time:
		_switching_camera = false
		_catch_player_counter = 0.0

func _follow_player() -> void:
	match _room_camera_axis_lock:
		"X":
			global_position.x = _player.global_position.x
		"Y":
			global_position.y = _player.global_position.y
		_:
			global_position = _player.global_position

func _look_ahead(delta: float) -> void:
	var weight := 1.0 - exp(-look_ahead_speed * delta)
	if is_zero_approx(_player.velocity.x):
		var target_x := look_ahead_offset if _player.is_facing_right() else -look_ahead_offset
		offset.x = lerpf(offset.x, target_x, weight)
	else:
		offset.x = lerpf(offset.x, 0.0, weight)
	
	offset.y = lerpf(offset.y, follow_offset.y, weight)
