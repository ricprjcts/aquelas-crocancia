extends Node
class_name SpriteController

@export var sprite: CanvasItem

@export_group("Blink Settings")
@export var blink_value: float = 1.0
@export var blink_duration: float = 0.5
@export var blink_ease: Tween.EaseType = Tween.EASE_OUT
@export var blink_transition: Tween.TransitionType = Tween.TRANS_CUBIC


func blink() -> void:
	var tween := create_tween()
	tween.tween_method(_set_blink_intensity, blink_value, 0.0, blink_duration).set_ease(blink_ease).set_trans(blink_transition)

func _set_blink_intensity(value: float) -> void:
	var material: ShaderMaterial = sprite.material
	if material:
		material.set_shader_parameter("blink_intensity", value)
