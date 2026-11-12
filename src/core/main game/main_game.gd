extends Node
class_name MainGame

static var current: MainGame = null

signal scene_freed
signal scene_loaded

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
	
	await get_tree().physics_frame
	
	_init_player(PLAYER_SCENE_UID)

func load_scene(scene_uid: String) -> void:
	if is_instance_valid(current_scene):
		var screen_transition: ScreenTransition = _instantiate_screen_transition()
		transition_root.add_child(screen_transition)
		screen_transition.anim.play_backwards("fade")
		
		await screen_transition.anim.animation_finished
		
		_free_entities()
		_set_player_camera(false)
		
		current_scene.queue_free()
		current_scene = null
		
		scene_freed.emit()
		
		screen_transition.queue_free()
	
	var new_level_packed: PackedScene = ResourceLoader.load(scene_uid, "PackedScene")
	
	if new_level_packed == null:
		push_error("Could not load scene as PackedScene", scene_uid)
		return
	
	var new_level: Node = new_level_packed.instantiate()
	if new_level == null:
		push_error("Could not instantiate level", scene_uid)
		return
	
	if new_level is not BaseLevel:
		push_error("Scene is not BaseLevel", scene_uid)
		new_level.free()
		return
	
	current_scene = new_level
	level_root.add_child(current_scene)
	
	scene_loaded.emit()
	
	var screen_transition: ScreenTransition = _instantiate_screen_transition()
	transition_root.add_child(screen_transition)
	screen_transition.anim.play("fade")
	
	_set_player_camera(true)
	
	await screen_transition.anim.animation_finished
	
	screen_transition.queue_free()

func _free_entities() -> void:
	for entity: CharacterBody2D in entities_root.get_children():
		if entity is Player:
			continue
		entity.queue_free()

func _instantiate_screen_transition() -> ScreenTransition:
	var screen_transition := SCREEN_TRANSITION_SCENE.instantiate()
	if screen_transition == null:
		push_error("Could not instantiate screen transition")
		return
	
	if screen_transition is not ScreenTransition:
		return
	
	return screen_transition

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
	
	_init_game_hud()
	_place_player_at_default_spawn()
	_set_player_camera(true)
	
	entities_root.add_child(player)

func _place_player_at_default_spawn() -> void:
	if player == null or current_scene == null:
		return
	
	var spawn_pos: Vector2 = current_scene.get_player_default_spawn()
	player.global_position = spawn_pos

func _set_player_camera(state: bool) -> void:
	if player == null or current_scene == null:
		return
	
	var player_camera: PlayerCamera = current_scene.get_player_camera()
	match state:
		true:
			player_camera.init(player)
		false:
			player_camera.disable()
