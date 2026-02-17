extends Control
@export var HealthBar:TextureProgressBar
@export var player:Node2D





func update_health(health:float)->void:
	HealthBar.value = health

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.health_changed.connect(update_health)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
