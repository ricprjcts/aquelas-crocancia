@icon("res://icons/node2d/skull_and_crossbones.svg")

extends CombatRoom
class_name GauntletRoom

@export var gauntlet_manager: GauntletManager
@export var gauntlet_start_delay: float = 1.0

func _ready() -> void:
	super()
	gauntlet_manager.gauntlet_cleared.connect(_on_gauntlet_cleared, CONNECT_ONE_SHOT)

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
