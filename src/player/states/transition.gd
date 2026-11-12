extends BaseState

@export var speed_multi := 0.5
@export var gravity_multi := 0.5
@export var max_gravity_multi := 1.5
var multiplier := 0.0

var halfway := false

func enter() -> void:
	multiplier = gravity_multi
	
	if not MainGame.current.scene_loaded.is_connected(_on_level_loaded):
		MainGame.current.scene_loaded.connect(_on_level_loaded)
	
	if SceneManager.going_to == Vector2i.LEFT or SceneManager.going_to == Vector2i.RIGHT:
		movement.direction = 1.0 if player.facing_right else -1.0
	
	movement.set_stun(-1.0)

func exit() -> void:
	if MainGame.current.scene_loaded.is_connected(_on_level_loaded):
		MainGame.current.scene_loaded.disconnect(_on_level_loaded)
	halfway = false

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
	match halfway:
		false:
			player.velocity.y -= (movement.gravity * multiplier) * delta
		true:
			player.velocity.x = movement.direction * (movement.speed * speed_multi)
			player.velocity.y += movement.gravity * delta
	
	multiplier = minf(multiplier + (multiplier * delta), max_gravity_multi)

func _on_level_loaded() -> void:
	if SceneManager.going_to != Vector2i.DOWN:
		var timer := get_tree().create_timer(player.transition_stun_time)
		timer.timeout.connect(_on_transition_ended)
		movement.set_stun(player.transition_stun_time)
	else:
		var timer := get_tree().create_timer(player.transition_stun_time * 0.25)
		timer.timeout.connect(_on_transition_ended)
		movement.set_stun(player.transition_stun_time * 0.25)
	
	if SceneManager.going_to == Vector2i.UP:
		movement.direction = SceneManager.up_direction
		halfway = true

func _on_transition_ended() -> void:
	if player.hitbox_controller.is_disabled(player.hurtbox.collision):
		player.hitbox_controller.enable_hitbox(player.hurtbox.collision)
	
	if state_machine.active_state == self:
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])
