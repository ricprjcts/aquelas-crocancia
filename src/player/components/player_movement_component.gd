extends MovementComponent
class_name PlayerMovement

@export_group("Dash")
@export var dash_velocity := 200.0
@export var dash_duration := 0.3
@export var dash_gravity := 0.0
@export var dash_cooldown := 0.5
var dash_debounce := false
var dash_amount := 1
var dashing := false

@export_group("Attack")
@export var attack_damage := 1
@export var attack_duration := 0.5
@export var attack_cooldown := 0.5
var attack_debounce := false
var attacking := false

var dash := false
var attack := false

func wants_wall_jump() -> bool:
	return body.is_on_wall_only() and jump

func can_dash() -> bool:
	return not dash_debounce and dash_amount > 0 and not attacking and not is_stunned()

func do_dash() -> bool:
	return dash and can_dash()

func update_dash_amount() -> void:
	if body.is_on_floor() or body.is_on_wall_only():
		dash_amount = 1

func start_dash_cooldown() -> void:
	dash_debounce = true
	
	var timer = get_tree().create_timer(dash_cooldown)
	timer.timeout.connect(func(): dash_debounce = false)

func can_attack() -> bool:
	return not attack_debounce and not dashing and not is_stunned()

func do_attack() -> bool:
	return attack and can_attack()

func start_attack_cooldown() -> void:
	attack_debounce = true
	
	var timer = get_tree().create_timer(attack_cooldown)
	timer.timeout.connect(func(): attack_debounce = false)
