extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState
@export var dash: HState
@export var attack: HState
@export var wall: HState

@export var knockback_deceleration: float = 800.0
var knockback_duration: float = 0.0

func enter() -> void:
	body.was_on_knockback = false
	
	var timer := get_tree().create_timer(knockback_duration)
	timer.timeout.connect(_on_knockback_ended)

func exit() -> void:
	body.was_on_knockback = true

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, body.velocity.x, knockback_deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()
	
	if body.do_dash():
		switch_state.emit(dash)
		return
	
	if body.do_attack():
		switch_state.emit(attack)
		return
	
	if body.can_wall_grab():
		switch_state.emit(wall)
		return

func _on_knockback_ended() -> void:
	if state_machine.active_state == self:
		if body.is_on_floor():
			if movement.is_moving():
				switch_state.emit(move)
			else:
				switch_state.emit(idle)
		else:
			switch_state.emit(fall)
