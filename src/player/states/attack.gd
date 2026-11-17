extends BaseState

@export var combo_timer: Timer

@export_category("Attacks")
@export_group("First Attack")
@export var first_attack_duration: float = 0.3
@export var first_attack_delay: float = 0.0
@export var first_attack_knockback: Vector2 = Vector2(500.0, 0.0)

@export_group("Second Attack")
@export var second_attack_duration: float = 0.5
@export var second_attack_delay: float = 0.1

@export_group("Last Attack")
@export var last_attack_duration: float = 0.5
@export var last_attack_delay: float = 0.2
@export var last_atack_dash_velocity: float = 100.0
@export var last_attack_deceleration: float = 5.0
@export var last_attack_knockback: Vector2 = Vector2(500.0, 0.0)
var last_attack_counter: float = 0.0

@export_group("Self Knockback")
@export var self_knockback: Vector2 = Vector2(100.0, -50.0)
@export var knockback_duration: float = 0.5

var attack_duration: float = 0.0
var attack_delay: float = 0.0
var last_attack_iframes: float = last_attack_duration - last_attack_delay

func enter() -> void:
	if not player.hitbox.area_entered.is_connected(_on_player_hitbox_area_entered):
		player.hitbox.area_entered.connect(_on_player_hitbox_area_entered)
	
	if not combo_timer.is_stopped():
		combo_timer.stop()
	
	if player.can_combo and player.current_combo > 0 and player.current_combo < player.max_combo:
		player.current_combo += 1
	elif player.current_combo == 0 or player.current_combo == player.max_combo:
		player.current_combo = 1
	
	match player.current_combo:
		1:
			player.hitbox.damage = player.attack_damage
			player.hitbox.knockback_force = player.attack_knockback
			
			attack_duration = first_attack_duration
			attack_delay = first_attack_delay
		2:
			attack_duration = second_attack_duration
			attack_delay = second_attack_delay
		player.max_combo:
			player.hitbox.damage = player.last_attack_damage
			player.hitbox.knockback_force = last_attack_knockback
			
			attack_duration = last_attack_duration
			attack_delay = last_attack_delay
	
	var timer := get_tree().create_timer(attack_duration)
	timer.timeout.connect(_on_attack_ended)
	
	player.attacking = true
	
	if attack_delay != 0.0:
		var delay_timer := get_tree().create_timer(attack_delay)
		delay_timer.timeout.connect(_on_attack_delay_ended)
	else:
		player.hitbox_controller.enable_hitbox(player.hitbox.collision)
		player.can_flip = false

func exit() -> void:
	player.hitbox_controller.disable_hitbox(player.hitbox.collision)
	
	if player.current_combo == player.max_combo:
		player.start_attack_cooldown(player.max_combo_cooldown)
	else:
		player.start_attack_cooldown()
	
	last_attack_counter = 0.0
	
	player.attacking = false
	player.can_flip = true

func physics_process(delta: float) -> void:
	match player.current_combo:
		1:
			_first_attack(delta)
		2:
			_second_attack(delta)
		player.max_combo:
			_last_attack(delta)
	
	player.move_and_slide()
	
	if movement.fall and player.velocity.y < 0.0:
		player.velocity.y = 0.0

func _first_attack(delta: float) -> void:
	var target := movement.direction * movement.speed if movement.is_moving() else 0.0
	var friction := movement.acceleration if movement.is_moving() else movement.deceleration
	player.velocity.x = move_toward(player.velocity.x, target, friction * delta)
	player.velocity.y += movement.gravity * delta

func _second_attack(delta: float) -> void:
	var target := movement.direction * movement.speed if movement.is_moving() else 0.0
	var friction := movement.acceleration if movement.is_moving() else movement.deceleration
	player.velocity.x = move_toward(player.velocity.x, target, friction * delta)
	player.velocity.y += movement.gravity * delta

func _last_attack(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0.0, last_attack_deceleration * delta)
	player.velocity.y += movement.gravity * delta

func _on_attack_delay_ended() -> void:
	if state_machine.active_state == self:
		player.can_flip = false
		player.hitbox_controller.enable_hitbox(player.hitbox.collision)
		if player.current_combo == player.max_combo:
			player.health.set_invincibility(last_attack_iframes)
			player.velocity.x = last_atack_dash_velocity if player.facing_right else -last_atack_dash_velocity

func _on_attack_ended() -> void:
	if state_machine.active_state == self:
		combo_timer.start(player.combo_time)
		player.can_combo = true
		
		if player.is_on_floor():
			if movement.is_moving():
				change_state.emit(states[player.states.move])
			else:
				change_state.emit(states[player.states.idle])
		else:
			change_state.emit(states[player.states.fall])

func _on_player_hitbox_area_entered(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	
	var hurtbox := area as Hurtbox
	if hurtbox.body == player:
		return
	
	match player.current_combo:
		1:
			pass
		2:
			pass
		player.max_combo:
			player.knockback.apply_knockback(hurtbox.global_position, self_knockback, knockback_duration)

func _on_combo_timer_timeout() -> void:
	if not player.can_combo:
		return
	
	player.current_combo = 0
	player.can_combo = false
