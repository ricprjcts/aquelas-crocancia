extends Node

var transitioning := false

var going_to: Vector2i
var up_direction: float

var _main_game: MainGame = null

func change_scene_by_gate(gate: TransitionGate) -> void:
	if transitioning:
		return
	
	transitioning = true
	
	if _main_game == null:
		_main_game = MainGame.current
	
	_main_game.scene_load_failed.connect(_on_scene_load_failed, CONNECT_ONE_SHOT)
	_main_game.load_scene(gate.destination_scene_uid)
	
	going_to = gate.going_to
	up_direction = gate.up_direction
	_main_game.player.scene_transition()
	
	await _main_game.scene_loaded
	
	var current_level := _main_game.current_scene
	if current_level == null:
		return
	
	var spawn_pos := current_level.get_transition_gate_spawn(gate)
	if spawn_pos == current_level.default_spawn.global_position:
		_main_game.place_player_at_default_spawn()
		transitioning = false
		return
	
	_main_game.player.global_position = spawn_pos
	_main_game.screen_fade_out()

func _on_scene_load_failed() -> void:
	if _main_game == null:
		_main_game = MainGame.current
	
	_main_game.load_scene(_main_game.initial_scene_uid)
	transitioning = false
