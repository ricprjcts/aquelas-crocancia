@tool
extends Node2D
class_name GauntletManager

signal gauntlet_cleared

@export var total_waves: int = 1 :
	set(value):
		total_waves = maxi(0, value)
		waves_info.resize(total_waves)
		spawn_points.resize(total_waves)
		notify_property_list_changed()
	get():
		return total_waves
@export var between_waves_delay: float = 0.0
@export var waves_info: Array[GauntletWaveResource]
@export var spawn_points: Array[Marker2D] = []

var current_wave := -1
var _enemies_alive := -1
var _enemies_to_spawn := -1

func init() -> void:
	current_wave = 0
	_enemies_alive = 0
	_enemies_to_spawn = 0
	start_wave()

func start_wave() -> void:
	if current_wave <= -1 or _enemies_alive <= -1 or _enemies_to_spawn <= -1 or current_wave >= total_waves:
		return
	
	current_wave += 1
	_enemies_to_spawn = waves_info[current_wave - 1].wave_total_enemies
	
	var spawns_available := spawn_points.duplicate()
	spawns_available.shuffle()
	
	for i in _enemies_to_spawn:
		if spawns_available.is_empty():
			break
		
		var selected_spawn := spawns_available.pop_back() as Marker2D
		
		var new_enemy := _create_new_enemy()
		new_enemy.health.died.connect(_on_enemy_died)
		new_enemy.global_position = selected_spawn.global_position
		MainGame.current.entities_root.add_child(new_enemy)
		_enemies_alive += 1
		_enemies_to_spawn -= 1

func _on_enemy_died() -> void:
	_enemies_alive -= 1
	if _enemies_alive == 0 and _enemies_to_spawn == 0:
		if current_wave < total_waves:
			var timer := get_tree().create_timer(between_waves_delay)
			timer.timeout.connect(start_wave)
		else:
			gauntlet_cleared.emit()

func _create_new_enemy() -> Enemy:
	var enemy := load(waves_info[current_wave - 1].enemy_to_spawn_uid) as PackedScene
	if enemy == null:
		return
	
	var enemy_instance := enemy.instantiate() as Node2D
	if enemy_instance is not Enemy:
		return
	
	return enemy_instance as Enemy
