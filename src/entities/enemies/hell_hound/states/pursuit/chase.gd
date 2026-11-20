extends HState

@export var wander: HState
@export var turn: HState
@export var jump: HState
@export var fall: HState

@export var speed_multiplier: float = 2.0

@export var min_wait_time: float = 0.5
@export var max_wait_time: float = 5.0
var wait_time: float = 0.0

var player: Player
var player_direction: float

func enter() -> void:
	super()
	
	if body.player == null:
		parent_state.switch_state.emit(wander)
		return
	
	player = body.player as Player
	player_direction = signf(player.global_position.x - body.global_position.x)
	movement.direction = player_direction
	
	wait_time = randf_range(min_wait_time, max_wait_time)
	var timer := get_tree().create_timer(wait_time)
	timer.timeout.connect(_on_timer_timeout)

func physics_process(delta: float) -> void:
	player_direction = signf(player.global_position.x - body.global_position.x)
	
	body.velocity.x = move_toward(body.velocity.x, 
									player_direction * (movement.speed * speed_multiplier), 
									movement.acceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if not body.is_on_floor():
		switch_state.emit(fall)
		return
	
	if not body.is_player_near():
		parent_state.switch_state.emit(wander)
		return
	
	if body.is_at_ledge() and body.is_ledge_deep():
		if player.global_position.y <= body.global_position.y:
			switch_state.emit(jump)
		return
	
	if body.can_jump_over_wall():
		switch_state.emit(jump)
		return
	
	if player_direction == -movement.direction:
		switch_state.emit(turn)
		return

func _on_timer_timeout() -> void:
	if parent_state.active_state == self:
		parent_state.switch_state.emit(wander)
