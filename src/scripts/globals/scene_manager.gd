extends Node

var going_to: Vector2i
var up_direction: float

func change_scene_by_gate(gate: TransitionGate) -> void:
	var main_game := MainGame.current
	main_game.load_scene(gate.destination_scene_uid)
	
	going_to = gate.going_to
	up_direction = gate.up_direction
	
	await main_game.scene_loaded
	
	var current_level := main_game.current_scene
	if current_level == null:
		return
	
	var spawn_pos := current_level.get_transition_gate_spawn(gate)
	if spawn_pos == Vector2.ZERO:
		main_game._place_player_at_default_spawn()
		return
	
	main_game.player.global_position = spawn_pos
