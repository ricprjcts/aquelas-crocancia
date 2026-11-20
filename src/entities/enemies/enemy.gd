@icon("res:///icons/node2d/skull.svg")
extends CharacterEntity
class_name Enemy

@export var detection_threshold: float = 50.0
@export var spawn_time: float = 0.7

var player: Player = null

func _ready() -> void:
	super()
	
	player = MainGame.current.player

func is_player_near() -> bool:
	if player == null:
		return false

	var distance := detection_threshold ** 2

	return global_position.distance_squared_to(player.global_position) <= distance
