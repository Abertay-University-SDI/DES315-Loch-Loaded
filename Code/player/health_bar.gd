extends Control
@export var HealthBar: TextureProgressBar
@export var sprayBar: TextureProgressBar
@export var player: Node2D
@export var dialog: NinePatchRect

var _target_health: float
var _target_spray: float

func update_health(health: float) -> void:
	_target_health = health

func update_spray(spray:float) -> void:
	_target_spray += spray

func getSprayValue() -> int:
	print_debug(sprayBar.value)
	return _target_spray

func _ready() -> void:
	visible = true
	_target_health = HealthBar.value
	_target_spray = 0
	player.health_changed.connect(update_health)
	player.spray_changed.connect(update_spray)

func _process(delta: float) -> void:
	HealthBar.value = lerpf(HealthBar.value, _target_health, delta * 10.0)
	sprayBar.value = lerpf(sprayBar.value, _target_spray, delta * 10.0)
