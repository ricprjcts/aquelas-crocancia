extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var transition_stun_time: float = 0.5
@export var up_speed := 120.0
@export var up_accel := 600.0  
@export var up_pop_height := 40.0
@export var speed_multi := 0.5
@export var deceleration: float = 5.0

var at_new_level := false

func enter() -> void:
	body.dash = false
	body.attack = false
	movement.jump = false
	movement.set_stun(-1.0)
	
	MainGame.current.scene_loaded.connect(_on_level_loaded, CONNECT_ONE_SHOT)
	
	if SceneManager.going_to == Vector2i.LEFT or SceneManager.going_to == Vector2i.RIGHT:
		movement.direction = float(SceneManager.going_to.x)
	else:
		if SceneManager.going_to == Vector2i.UP:
			body.velocity.y = movement.jump_velocity
		movement.direction = 0.0

func exit() -> void:
	if body.hitbox_controller.is_disabled(body.hurtbox.collision):
		body.hitbox_controller.enable_hitbox(body.hurtbox.collision)
		
	SceneManager.transitioning = false
	at_new_level = false

func physics_process(delta: float) -> void:
	if SceneManager.going_to == Vector2i.LEFT or SceneManager.going_to == Vector2i.RIGHT:
		_horizontal_transition(delta)
	else:
		match SceneManager.going_to:
			Vector2i.DOWN:
				_down_transition(delta)
			Vector2i.UP:
				_up_transition(delta)
	
	body.move_and_slide()

func _horizontal_transition(delta: float) -> void:
	body.velocity.x = movement.direction * movement.speed
	body.velocity.y += movement.gravity * delta

func _down_transition(delta: float) -> void:
	body.velocity.x = 0.0
	body.velocity.y += movement.gravity * delta

func _up_transition(delta: float) -> void:
	if not at_new_level:
		body.velocity.x = move_toward(body.velocity.x, 0.0, movement.speed * deceleration)
		body.velocity.y = move_toward(body.velocity.y, -up_speed, up_accel * delta)
	else:
		body.velocity.x = movement.direction * movement.speed * speed_multi
		body.velocity.y += movement.gravity * delta

func _on_level_loaded() -> void:
	var stun_time := transition_stun_time
	if SceneManager.going_to == Vector2i.DOWN:
		stun_time *= 0.25
		body.velocity.y *= 0.1
	
	if SceneManager.going_to == Vector2i.UP:
		body.velocity.y = -sqrt(2.0 * movement.gravity * up_pop_height)
		movement.direction = SceneManager.up_direction
		at_new_level = true
	
	get_tree().create_timer(stun_time).timeout.connect(_on_transition_ended)
	movement.set_stun(stun_time)

func _on_transition_ended() -> void:
	if state_machine.active_state == self:
		if body.is_on_floor():
			if movement.is_moving():
				switch_state.emit(move)
			else:
				switch_state.emit(idle)
		else:
			switch_state.emit(fall)
