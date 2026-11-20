extends Node
class_name MainGame

static var current: MainGame = null

signal scene_freed
signal scene_loaded
signal scene_load_failed

signal fade_in_finished

const SCREEN_TRANSITION_SCENE: PackedScene = preload("uid://dgrrdm2pqs3fj")

const GAME_HUD_SCENE_UID: String = "uid://bmmkahla2j6q8"
const PLAYER_SCENE_UID: String = "uid://r188evn2vwhw"

@export var initial_scene_uid: String = ""

@onready var level_root: Node2D = %LevelRoot
@onready var entities_root: Node2D = %EntitiesRoot
@onready var effects_root: Node2D = %EffectsRoot

@onready var hud_root: Control = %HudRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot

var current_scene: BaseLevel = null
var player: Player = null

func _ready() -> void:
	current = self
	
	load_scene(initial_scene_uid)
	
	_init_player(PLAYER_SCENE_UID)

func load_scene(scene_uid: String) -> void:
	if is_instance_valid(current_scene):
		screen_fade_in()
		
		await fade_in_finished
		
		_free_entities()
		_set_player_camera(false)
		
		current_scene.queue_free()
		current_scene = null
		
		scene_freed.emit()
	
	var new_level_packed: PackedScene = ResourceLoader.load(scene_uid, "PackedScene")
	
	if new_level_packed == null:
		push_error("Could not load scene as PackedScene", scene_uid)
		scene_load_failed.emit()
		return
	
	var new_level: Node = new_level_packed.instantiate()
	if new_level == null:
		push_error("Could not instantiate level", scene_uid)
		scene_load_failed.emit()
		return
	
	if new_level is not BaseLevel:
		push_error("Scene is not BaseLevel", scene_uid)
		new_level.free()
		scene_load_failed.emit()
		return
	
	current_scene = new_level
	level_root.add_child(current_scene)
	
	scene_loaded.emit()
	
	_set_player_camera()

func screen_fade_in() -> void:
	var screen_transition := SCREEN_TRANSITION_SCENE.instantiate() as ScreenTransition
	if screen_transition == null:
		push_error("Could not instantiate screen transition")
		return
	
	transition_root.add_child(screen_transition)
	screen_transition.anim.play_backwards("fade")
	
	await screen_transition.anim.animation_finished
	
	fade_in_finished.emit()

func screen_fade_out() -> void:
	var screen_transition := transition_root.get_node_or_null("ScreenTransition") as ScreenTransition
	if screen_transition == null:
		screen_transition = SCREEN_TRANSITION_SCENE.instantiate() as ScreenTransition
		transition_root.add_child(screen_transition)
	
	if screen_transition == null:
		push_error("Could not load screen transition")
		return
	
	screen_transition.anim.play("fade")
	
	await screen_transition.anim.animation_finished
		
	screen_transition.queue_free()

func place_player_at_default_spawn() -> void:
	if player == null or current_scene == null:
		return
	
	var spawn_pos: Vector2 = current_scene.get_player_default_spawn()
	player.global_position = spawn_pos

func _free_entities() -> void:
	for entity: CharacterEntity in entities_root.get_children():
		if entity is Player:
			continue
		
		entity.queue_free()

func _init_game_hud() -> void:
	if player == null or current_scene == null:
		return
	
	var game_hud_scene: PackedScene = ResourceLoader.load(GAME_HUD_SCENE_UID, "PackedScene") as PackedScene
	if game_hud_scene == null:
		return
	
	var new_game_hud: GameHud = game_hud_scene.instantiate() as Control
	if new_game_hud == null:
		return
	
	if new_game_hud is not GameHud:
		return
	
	hud_root.add_child(new_game_hud)

func _init_player(player_scene_uid: String) -> void:
	if current_scene == null:
		return
	
	var player_scene: PackedScene = ResourceLoader.load(player_scene_uid, "PackedScene")
	if player_scene == null:
		push_error("Could not load player scene", player_scene_uid)
		return
	
	var player_instance: Node = player_scene.instantiate()
	if player_instance == null:
		push_error("Could not instantiate player scene", player_scene_uid)
		return
	
	if player_instance is not Player:
		return
	
	player = player_instance
	
	place_player_at_default_spawn()
	_set_player_camera()
	_init_game_hud()
	
	entities_root.add_child(player)

func _set_player_camera(state: bool = true) -> void:
	if player == null or current_scene == null:
		return
	
	var player_camera: PlayerCamera = current_scene.get_player_camera()
	if state:
		player_camera.init(player)
	else:
		player_camera.disable()
