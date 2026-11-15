@tool
extends Camera2D
class_name RoomCamera

@export var follow_enabled: bool = false:
	set(value):
		follow_enabled = value
		notify_property_list_changed()

@export_enum("None", "X", "Y") var axis_lock: String = "None"
@export var tween_resource: TweenResource

func _validate_property(property: Dictionary) -> void:
	if property.name == "axis_lock" and not follow_enabled:
		property.usage = PROPERTY_USAGE_NO_EDITOR
