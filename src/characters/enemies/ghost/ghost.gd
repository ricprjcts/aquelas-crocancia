extends BaseEnemy

@export_category("Values")
@export var respawn_enabled := false
@export var damage_stun := 0.05
@export var damage_iframes := 0.1

@onready var anim: AnimationPlayer = $Anim

func init() -> void:
	health_component.set_invincibility(0.7)
	movement_component.set_stun(0.7)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	velocity.y += movement_component.gravity * delta
	
	if not movement_component.is_stunned():
		velocity.x = 0.0
	
	move_and_slide()

func _on_damage_taken(amount: int) -> void:
	health_component.set_invincibility(damage_iframes)
	movement_component.set_stun(damage_stun)
	sprite_controller.blink()

func _on_died() -> void:
	hitbox_controller.disable_hitbox(hitbox.collision)
	hitbox_controller.disable_hitbox(hurtbox.collision)
	movement_component.set_stun(damage_stun)
	sprite_controller.blink()
	anim.play("vanish")
	await anim.animation_finished
	if respawn_enabled:
		spawner.load_entity()
	queue_free()
