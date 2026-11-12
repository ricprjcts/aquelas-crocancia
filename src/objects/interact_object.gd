extends AnimatedSprite2D
class_name InteractObject

@export var interact_component: InteractComponent

var interact_enabled := false
var _player: Player = null

func _ready() -> void:
	interact_component.interact_enabled.connect(_on_interact_enabled)
	interact_component.interact_disabled.connect(_on_interact_disabled)

func _process(delta: float) -> void:
	if not interact_enabled or _player == null:
		return
	
	if _player.is_interacting():
		_on_interact()

func _on_interact() -> void:
	pass

func _on_interact_enabled(player: Player) -> void:
	_player = player
	if player == null:
		return
	
	interact_enabled = true

func _on_interact_disabled() -> void:
	_player = null
	interact_enabled = false
