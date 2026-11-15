extends Node2D
class_name BaseLevel

@export_category("Player")
@export var default_spawn: Marker2D
@export var player_camera: PlayerCamera

@export_category("Nodes")
@export var transitions: Node2D

func get_player_default_spawn() -> Vector2:
	return default_spawn.global_position

func get_player_camera() -> PlayerCamera:
	return player_camera

func get_transition_gate_spawn(gate: TransitionGate) -> Vector2:
	var gates := _get_transition_gates()
	if gates == []:
		return get_player_default_spawn()
	
	for new_gate: TransitionGate in gates:
		if new_gate is not TransitionGate:
			continue
		
		if gate.going_to == new_gate.coming_from and gate.match_number == new_gate.match_number:
			var gate_spawn := new_gate.spawn
			return gate_spawn.global_position
	
	return get_player_default_spawn()

func _get_transition_gates() -> Array[Node]:
	if transitions == null:
		return []
	
	return transitions.get_children()
