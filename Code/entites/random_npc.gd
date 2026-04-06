extends Node2D

@onready var sprite:Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.frame = randi_range(0,sprite.hframes - 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
