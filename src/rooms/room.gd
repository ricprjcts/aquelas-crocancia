@icon("res://icons/node2d/house.svg")
@abstract
extends Node2D
class_name Room

@export var room_area: RoomArea

func _ready() -> void:
	room_area.body_entered.connect(_on_room_area_body_entered)

func _on_room_area_body_entered(body: Node2D) -> void:
	pass
