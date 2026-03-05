extends Control
@export var HealthBar: TextureProgressBar
@export var player: Node2D
@export var dialog: NinePatchRect

var _target_health: float

func update_health(health: float) -> void:
	_target_health = health

func _ready() -> void:
	visible = true
	_target_health = HealthBar.value
	player.health_changed.connect(update_health)

func _process(delta: float) -> void:
	HealthBar.value = lerpf(HealthBar.value, _target_health, delta * 10.0)
