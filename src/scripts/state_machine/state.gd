@icon("res://icons/animation/square.svg")

extends Node
class_name HState

signal switch_state(state: HState)

@export_node_path("AnimationPlayer", "AnimatedSprite2D") var animation_player: NodePath = ^""
@export var animation_name: StringName = &""
var can_play_anim: bool = false

@export var initial_state: HState = null
var active_state: HState = null

@onready var animation_node := get_node_or_null(animation_player)

var state_machine: HStateMachine = null
var parent_state: HState = null
var body: CharacterEntity = null
var movement: MovementComponent = null

func init_state() -> void:
	var has_sub_states := not get_children().is_empty()
	if not has_sub_states:
		return
		
	for child: Node in get_children():
		if child is not HState:
			continue
		
		var sub_state := child as HState
		sub_state.switch_state.connect(change_sub_state)
		
		sub_state.state_machine = state_machine
		sub_state.parent_state = self
		sub_state.body = body
		sub_state.movement = movement
	
	if initial_state != null:
		active_state = initial_state
		active_state.enter()

func enter() -> void:
	can_play_anim = animation_node != null and animation_name != "" and animation_node.has_method(&"play")
	if can_play_anim and not movement.is_stunned():
		animation_node.play(animation_name)
	
	if initial_state != null:
		active_state = initial_state
		active_state.enter()

func exit() -> void:
	if active_state != null:
		active_state.exit()
		active_state = null

func process(delta: float) -> void:
	if active_state != null:
		active_state.process(delta)

func physics_process(delta: float) -> void:
	if active_state != null:
		active_state.physics_process(delta)

func change_sub_state(new_state: HState) -> void:
	if active_state != null:
		active_state.exit()
	
	active_state = new_state
	active_state.enter()
