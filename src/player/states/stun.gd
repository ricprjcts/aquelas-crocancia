extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var deceleration: float = 5.0

var stun_time := 0.0

func enter() -> void:
	movement.set_stun(stun_time)
	movement.direction = 0.0
	
	var timer := get_tree().create_timer(stun_time)
	timer.timeout.connect(_on_stun_ended)

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

func _on_stun_ended() -> void:
	if state_machine.active_state == self:
		if body.is_on_floor():
			if movement.is_moving():
				switch_state.emit(move)
			else:
				switch_state.emit(idle)
		else:
			switch_state.emit(fall)
