@icon("res://icons/node2d/sword.svg")

extends Area2D
class_name Hitbox

@export var body: Node2D
@export var collision: CollisionShape2D

@export var damage := 1
@export var knockback_duration: float = 0.5
@export var knockback_force: Vector2 = Vector2(100.0, -150.0)

func _ready() -> void:
	_set_collision()
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	
	var hurtbox = area as Hurtbox
	var target := hurtbox.body as Node2D
	
	if target == body or (body is Enemy and target is Enemy):
		return
	
	if not target.has_method(&"take_damage") or target == null:
		return
	
	var hit_data := HitData.new(damage, global_position, knockback_force, knockback_duration)
	target.take_damage(hit_data)

func _set_collision() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	set_collision_layer_value(3, true)
	set_collision_mask_value(4, true)
