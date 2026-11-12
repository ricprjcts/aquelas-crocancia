extends Node
class_name MovementComponent

@export_group("Body")
@export var body: CharacterBody2D

@export_group("Base Movement")
@export var speed := 100.0
@export var jump_velocity := -200.0
@export var gravity := 500.0

var direction := 0.0
var jump := false
var fall := false

var stunned := false
var dead := false

func is_moving() -> bool:
	return direction != 0.0

func is_stunned() -> bool:
	return stunned or dead

func wants_jump() -> bool:
	return body.is_on_floor() and jump

func set_stun(duration: float, value: bool = true) -> void:
	stunned = value
	
	if duration <= -1.0:
		return
	
	var timer := get_tree().create_timer(duration)
	timer.timeout.connect(func():
		stunned = !stunned
		)
