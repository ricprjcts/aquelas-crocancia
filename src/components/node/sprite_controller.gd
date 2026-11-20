extends Component
class_name SpriteController

@export var sprite: CanvasItem

@export_group("Blink Settings")
@export_subgroup("Damage")
@export var damage_blink_value: float = 1.0
@export var damage_blink_duration: float = 0.5
@export var damage_blink_ease: Tween.EaseType = Tween.EASE_OUT
@export var damage_blink_transition: Tween.TransitionType = Tween.TRANS_CUBIC

func blink() -> void:
	if not sprite or not sprite.material: return
	var material: ShaderMaterial = sprite.material
	var tween := create_tween()
	
	tween.tween_method(func(v): material.set_shader_parameter("blink_intensity", v), damage_blink_value, 0.0, damage_blink_duration).set_ease(damage_blink_ease).set_trans(damage_blink_transition)

func flash(flash_count: int, flash_duration: float, decay_rate: float, ease_type: Tween.EaseType) -> void:
	if not sprite or not sprite.material: return

	var material: ShaderMaterial = sprite.material
	var tween := create_tween()

	var duration: float = flash_duration
	for i in flash_count:
		match ease_type:
			Tween.EaseType.EASE_IN_OUT:
				tween.tween_method(func(v): material.set_shader_parameter("flash_amount", v), 0.0, 1.0, duration)
				tween.tween_method(func(v): material.set_shader_parameter("flash_amount", v), 1.0, 0.0, duration)
			Tween.EaseType.EASE_OUT:
				tween.tween_method(func(v): material.set_shader_parameter("flash_amount", v), 1.0, 0.0, duration)
		
		duration = maxf(duration * decay_rate, 0.02)
