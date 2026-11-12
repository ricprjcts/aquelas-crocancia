extends Camera2D
class_name PlayerCamera

static var current: PlayerCamera = null

@export var look_ahead_offset: float = 4.0
@export var look_ahead_weight: float = 1.0

var _player: Player = null

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	_follow_player()
	_look_ahead()

func init(player: Player) -> void:
	current = self
	_player = player
	set_process(true)

func disable() -> void:
	set_process(false)
	current = null
	_player = null

func _follow_player() -> void:
	global_position = _player.global_position

func _look_ahead() -> void:
	if _player.movement.is_moving() or _player.movement.dashing:
		if _player.is_facing_right():
			offset.x = lerpf(offset.x, look_ahead_offset, look_ahead_weight)
		else:
			offset.x = lerpf(offset.x, -look_ahead_offset, look_ahead_weight)
	else:
		offset.x = lerpf(offset.x, 0.0, look_ahead_weight)
