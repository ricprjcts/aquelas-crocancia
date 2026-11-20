@icon("res://icons/node2d/swords.svg")

extends Room
class_name CombatRoom

@export var enabled: bool = true
@export var door_controller: DoorController

func _ready() -> void:
	super()
