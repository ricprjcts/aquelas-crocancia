extends BaseState

@export var up_speed := 120.0
@export var up_accel := 600.0  
@export var up_pop_height := 40.0
@export var speed_multi := 0.5
@export var deceleration: float = 5.0

var at_new_level := false

func enter() -> void:
	movement.jump = false
	player.dash = false
	player.attack = false
	
	if not MainGame.current.scene_loaded.is_connected(_on_level_loaded):
		MainGame.current.scene_loaded.connect(_on_level_loaded)
	
	if SceneManager.going_to == Vector2i.LEFT or SceneManager.going_to == Vector2i.RIGHT:
		movement.direction = float(SceneManager.going_to.x)
	else:
		if SceneManager.going_to == Vector2i.UP:
			player.velocity.y = movement.jump_velocity
		
		movement.direction = 0.0
	
	movement.set_stun(-1.0)

func exit() -> void:
	SceneManager.transitioning = false
	at_new_level = false
	
	if player.hitbox_controller.is_disabled(player.hurtbox.collision):
		player.hitbox_controller.enable_hitbox(player.hurtbox.collision)

func physics_process(delta: float) -> void:
	if SceneManager.going_to == Vector2i.LEFT or SceneManager.going_to == Vector2i.RIGHT:
		_horizontal_transition(delta)
	else:
		match SceneManager.going_to:
			Vector2i.DOWN:
				_down_transition(delta)
			Vector2i.UP:
				_up_transition(delta)
	
	player.move_and_slide()

func _horizontal_transition(delta: float) -> void:
	player.velocity.x = movement.direction * movement.speed
	player.velocity.y += movement.gravity * delta

func _down_transition(delta: float) -> void:
	player.velocity.x = 0.0
	player.velocity.y += movement.gravity * delta

func _up_transition(delta: float) -> void:
	if not at_new_level:
		player.velocity.x = move_toward(player.velocity.x, 0.0, movement.speed * deceleration)
		player.velocity.y = move_toward(player.velocity.y, -up_speed, up_accel * delta)
	else:
		player.velocity.x = movement.direction * movement.speed * speed_multi
		player.velocity.y += movement.gravity * delta

func _on_level_loaded() -> void:
	var stun_time := player.transition_stun_time
	if SceneManager.going_to == Vector2i.DOWN:
		stun_time *= 0.25
		player.velocity.y *= 0.1
	
	get_tree().create_timer(stun_time).timeout.connect(_on_transition_ended)
	movement.set_stun(stun_time)
	
	if SceneManager.going_to == Vector2i.UP:
		movement.direction = SceneManager.up_direction
		at_new_level = true
		player.velocity.y = -sqrt(2.0 * movement.gravity * up_pop_height)

func _on_transition_ended() -> void:
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
