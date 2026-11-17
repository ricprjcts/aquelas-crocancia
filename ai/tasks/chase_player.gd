extends BTAction

@export var min_chase_duration: float = 1.0
@export var max_chase_duration: float = 5.0

var chase_duration: float = 0.0
var chase_timer: float = 0.0

var direction: float = 0.0

var player: Player = null

func _enter() -> void:
	chase_duration = randf_range(min_chase_duration, max_chase_duration)
	
	player = blackboard.get_var("player") as Player
	
	direction = signf(player.global_position.x - agent.global_position.x)

func _exit() -> void:
	blackboard.set_var("state", "patrol")
	
	agent.velocity.x = 0.0
	direction = 0.0
	
	chase_timer = 0.0

func _tick(delta: float) -> Status:
	agent.move(direction)
	
	chase_timer += delta
	if chase_timer >= chase_duration:
		return SUCCESS
	
	if absf(agent.global_position.x - player.global_position.x) <= 8.0:
		return SUCCESS
	
	if absf(agent.global_position.x - player.global_position.x) <= 16.0 and player.global_position.y < agent.global_position.y - 16.0:
		return SUCCESS
	
	if agent.is_at_ledge_or_wall():
		return SUCCESS
	
	return RUNNING
