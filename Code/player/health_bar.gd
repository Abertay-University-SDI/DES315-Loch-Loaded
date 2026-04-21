extends Control
@onready var HealthBar: TextureProgressBar = $HealthBar
@export var player: Node2D
@export var dialog: NinePatchRect
@export var sprayLabel: Label

@onready var dash: TextureRect = $Cooldowns/Dash
@onready var slam: TextureRect = $Cooldowns/Slam
@onready var shock: TextureRect = $Cooldowns/Shock


var _target_health: float
var _target_spray: int

func update_health(health: float) -> void:
	_target_health = health
	
func update_cooldowns(dashcd,slamcd,shockcd)->void:
	var dash_mat = dash.material as ShaderMaterial
	dash_mat.set_shader_parameter("cooldown",dashcd)
	var slam_mat = slam.material as ShaderMaterial
	slam_mat.set_shader_parameter("cooldown",slamcd)
	var shock_mat = shock.material as ShaderMaterial
	shock_mat.set_shader_parameter("cooldown",shockcd)
	

func update_spray(spray:int) -> void:
	_target_spray += spray
	sprayLabel.text = str(_target_spray) + "/4"

func getSprayValue() -> float:
	return _target_spray

func _ready() -> void:
	visible = true
	_target_health = HealthBar.value
	_target_spray = 3
	update_spray(0)
	player.health_changed.connect(update_health)
	player.spray_changed.connect(update_spray)
	player.cooldowns.connect(update_cooldowns)

func _process(delta: float) -> void:
	HealthBar.value = lerpf(HealthBar.value, _target_health, delta * 10.0)
