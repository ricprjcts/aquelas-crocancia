extends Node2D
class_name DoorController

@export var doors: Array[Door] = []

func open_all_doors() -> void:
	if doors.is_empty():
		return
	
	for door: Door in doors:
		if not _is_door_closed(door):
			return
		
		door.collision.set_deferred("disabled", true)

func close_all_doors() -> void:
	if doors.is_empty():
		return
	
	for door: Door in doors:
		if _is_door_closed(door):
			return
		
		door.collision.set_deferred("disabled", false)

func _is_door_closed(door: Door) -> bool:
	return not door.collision.disabled
