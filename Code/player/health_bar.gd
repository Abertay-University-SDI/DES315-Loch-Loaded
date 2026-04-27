extends Control
@onready var HealthBar: TextureProgressBar = $HealthBar
@export var player: Node2D
@export var dialog: NinePatchRect

@onready var numerator: Label = $HBoxContainer/Fraction/Numerator
@onready var denominator: Label = $HBoxContainer/Fraction/Denominator
@onready var fraction: GridContainer = $HBoxContainer/Fraction



@onready var dash: TextureRect = $Cooldowns/Dash
@onready var slam: TextureRect = $Cooldowns/Slam
@onready var shock: TextureRect = $Cooldowns/Shock


@export var Enough_Cans_color :Color=Color.LIME
@export var not_Enough_Cans_color:Color= Color.RED


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
	var Spray_max = Global.spray_cans_needed
	var color = Color.WHITE
	_target_spray += spray
	numerator.text = str(_target_spray)
	denominator.text = str(Spray_max)
	
	if Spray_max <= _target_spray:
		color = Enough_Cans_color
	else:
		color = not_Enough_Cans_color
		
	for label in fraction.get_children():
		label.add_theme_color_override("font_color",color)

	

func getSprayValue() -> float:
	return _target_spray

func _ready() -> void:
	if (Global.getGameModeEasy()):
		HealthBar.max_value = 200
		HealthBar.value = 200
	visible = true
	_target_health = HealthBar.value
	_target_spray = 0
	update_spray(0)
	player.health_changed.connect(update_health)
	player.spray_changed.connect(update_spray)
	player.cooldowns.connect(update_cooldowns)

func _process(delta: float) -> void:
	HealthBar.value = lerpf(HealthBar.value, _target_health, delta * 10.0)
