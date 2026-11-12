extends Area2D
class_name TransitionGate

@export var destination_scene_uid: String = ""
@export var spawn: Marker2D
@export_range(0.0, 3.0) var match_number: int = 0
@export var going_to: Vector2i = Vector2.ZERO
@export var coming_from: Vector2i = Vector2.ZERO
@export_range(-1.0, 1.0, 1.0) var up_direction: float

func _ready() -> void:
	_set_collision()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Node2D) -> void:
	if area is not Hurtbox:
		return
	var hurtbox := area as Hurtbox
	if hurtbox.body is not Player:
		return
	
	var player := hurtbox.body
	player.scene_transition()
	
	SceneManager.change_scene_by_gate(self)

func _set_collision() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_mask_value(4, true)
