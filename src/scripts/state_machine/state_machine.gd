@icon("res://icons/animation/flowchart.svg")

extends Node
class_name HStateMachine

@export var initial_state: HState = null
var active_state: HState = null

func init(body: CharacterEntity, movement: MovementComponent) -> void:
	for state: HState in get_children():
		state.switch_state.connect(change_state)
		state.state_machine = self
		
		state.body = body
		state.movement = movement
		state.init_state()
		
	if initial_state != null:
		active_state = initial_state
		active_state.enter()

func process(delta: float) -> void:
	if active_state != null:
		active_state.process(delta)

func physics_process(delta: float) -> void:
	if active_state != null:
		active_state.physics_process(delta)

func change_state(new_state: HState) -> void:
	if active_state != null:
		active_state.exit()

	active_state = new_state
	active_state.enter()
