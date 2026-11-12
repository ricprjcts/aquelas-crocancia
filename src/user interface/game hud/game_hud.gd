extends Control
class_name GameHud

@export var health_label: Label
@export var money_label: Label

func _ready() -> void:
	PlayerHelper.player_ready.connect(_on_player_ready)
	PlayerHelper.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(current_health: int, max_health: int) -> void:
	var health_string: String = str(current_health) + " / " + str(max_health)
	health_label.text = "Health: " + health_string

func _on_player_ready() -> void:
	var health_string: String = str(PlayerHelper.health) + " / " + str(PlayerHelper.max_health)
	health_label.text = "Health: " + health_string
