extends Control
@onready var HealthBar: TextureProgressBar = $HealthBar
@export var player: Node2D
@export var dialog: NinePatchRect
@export var sprayLabel: Label

var _target_health: float
var _target_spray: int

func update_health(health: float) -> void:
	_target_health = health

func update_spray(spray:int) -> void:
	_target_spray += spray
	sprayLabel.text = "X" + str(_target_spray)

func getSprayValue() -> float:
	return _target_spray

func _ready() -> void:
	visible = true
	_target_health = HealthBar.value
	_target_spray = 0
	player.health_changed.connect(update_health)
	player.spray_changed.connect(update_spray)

func _process(delta: float) -> void:
	HealthBar.value = lerpf(HealthBar.value, _target_health, delta * 10.0)
