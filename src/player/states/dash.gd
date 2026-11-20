extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var dash_velocity := 200.0
@export var dash_deceleration: float = 5.0
@export var dash_duration := 0.3
@export var dash_gravity := 0.0

func enter() -> void:
	super()
	
	body.dashing = true
	body.dash_amount -= 1
	body.can_flip = false
	
	body.velocity.x = dash_velocity if body.is_facing_right() else -dash_velocity
	
	var timer := get_tree().create_timer(dash_duration)
	timer.timeout.connect(_on_dash_ended)

func exit() -> void:
	body.start_dash_cooldown()
	body.dashing = false
	body.can_flip = true

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, dash_deceleration * delta)
	body.velocity.y = dash_gravity
	body.move_and_slide()

func _on_dash_ended() -> void:
	if state_machine.active_state == self:
		if body.is_on_floor():
			if movement.is_moving():
				switch_state.emit(move)
			else:
				switch_state.emit(idle)
		else:
			switch_state.emit(fall)
