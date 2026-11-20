extends HState

@export var wander: HState

@export var attack_duration: float = 0.5
@export var dash_velocity: float = 300.0
@export var dash_deceleration: float = 600.0
@export var attack_cooldown: float = 0.5
var attack_debounce := false
var attacking := false

func enter() -> void:
	super()

	if attack_debounce or attacking:
		switch_state.emit(wander)
		return

	var timer := get_tree().create_timer(attack_duration)
	timer.timeout.connect(_on_timer_ended)

	attacking = true
	movement.direction = signf(body.player.global_position.x - body.global_position.x)
	body.velocity.x = dash_velocity * movement.direction

func exit() -> void:
	attacking = false
	_set_attack_cooldown()

func physics_process(delta: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, dash_deceleration * delta)
	body.velocity.y += movement.gravity * delta
	body.move_and_slide()

func _set_attack_cooldown() -> void:
	if not attacking:
		attack_debounce = true
		var timer := get_tree().create_timer(attack_cooldown)
		timer.timeout.connect(func():
			attack_debounce = false
			)

func _on_timer_ended() -> void:
	if state_machine.active_state == self:
		switch_state.emit(wander)
