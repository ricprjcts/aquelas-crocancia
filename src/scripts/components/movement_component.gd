extends Node
class_name MovementComponent

@export_group("Body")
@export var body: CharacterBody2D

@export_group("Base Movement")
@export var speed := 100.0
@export var acceleration := 0.1
@export var deceleration := 0.1
@export var jump_velocity := -200.0
@export var gravity := 500.0

var direction := 0.0
var jump := false
var fall := false

var stunned := false
var dead := false

var _stun_token := 0

func is_moving() -> bool:
	return direction != 0.0

func is_stunned() -> bool:
	return stunned or dead

func wants_jump() -> bool:
	return body.is_on_floor() and jump

func set_stun(duration: float = -1.0, value: bool = true) -> void:
	_stun_token += 1
	stunned = value
	
	if duration <= -1.0:
		return
	
	var token := _stun_token
	get_tree().create_timer(duration).timeout.connect(func():
		if token == _stun_token:
			stunned = not value
	)
