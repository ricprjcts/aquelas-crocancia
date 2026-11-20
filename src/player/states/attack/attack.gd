extends HState

@export var idle: HState
@export var move: HState
@export var fall: HState

@export var first: HState
@export var second: HState
@export var last: HState

@export var combo_timer: Timer

@export_group("Combo")
@export var max_combo: int = 1
@export var max_combo_cooldown: float = 0.5
@export var combo_time: float = 1.0
var current_combo: int = 0
var can_combo: bool = false

func enter() -> void:
	super()
	
	if not combo_timer.is_stopped():
		combo_timer.stop()
	
	if can_combo and current_combo > 0 and current_combo < max_combo:
		current_combo += 1
	elif current_combo == 0 or current_combo >= max_combo:
		current_combo = 1
	
	match current_combo:
		1:
			change_sub_state(first)
		2:
			change_sub_state(second)
		max_combo:
			change_sub_state(last)

func physics_process(delta: float) -> void:
	super(delta)
	
	if body.velocity.y < 0 and movement.fall:
		body.velocity.y = 0.0
	
	body.move_and_slide()

func start_combo_timer() -> void:
	combo_timer.start(combo_time)
	can_combo = true

func _on_combo_timer_timeout() -> void:
	if not can_combo:
		return
	
	current_combo = 0
	can_combo = false
