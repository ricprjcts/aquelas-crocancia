extends Node
class_name BaseState

signal change_state(state: BaseState)

var state_machine: StateMachine
var states := {}

var player: Player
var movement: PlayerMovement

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(delta: float) -> void:
	pass

func physics_process(delta: float) -> void:
	pass
