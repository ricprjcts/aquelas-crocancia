extends Room
class_name GauntletRoom

@export var enabled: bool = true
@export var gauntlet_manager: GauntletManager
@export var gauntlet_start_delay: float = 1.0
@export var door_controller: DoorController

func init() -> void:
	gauntlet_manager.gauntlet_cleared.connect(_on_gauntlet_cleared)

func _on_room_area_body_entered(body: Node2D) -> void:
	if body is not Player or not enabled:
		return
	
	door_controller.close_all_doors()
	
	if gauntlet_start_delay != 0.0:
		await get_tree().create_timer(gauntlet_start_delay).timeout
	
	gauntlet_manager.init()
	enabled = false

func _on_gauntlet_cleared() -> void:
	door_controller.open_all_doors()
