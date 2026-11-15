extends Marker2D
class_name EntitySpawner

@export var enabled: bool = true

@export_group("Spawner")
@export_placeholder("UID") var scene_to_load: String = ""
@export var delay: float = 0.0

func _on_screen_notifier_screen_entered() -> void:
	if not enabled:
		return
	
	load_entity()

func load_entity() -> void:
	var entity_scene := load(scene_to_load) as PackedScene
	if entity_scene == null:
		return
	
	var new_entity := entity_scene.instantiate() as Node2D
	if new_entity == null:
		return
	
	if delay != 0.0:
		await get_tree().create_timer(delay).timeout
	
	var main_game := MainGame.current
	if main_game == null:
		return
	
	new_entity.global_position = global_position
	main_game.entities_root.add_child(new_entity)
	
	enabled = false
