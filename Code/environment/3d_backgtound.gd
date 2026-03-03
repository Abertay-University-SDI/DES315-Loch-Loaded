extends SubViewport

@export var cam_path:PathFollow3D
@export var player:CharacterBody2D
@export var bounds:Area2D
@export var bounds_shape:CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var shape :RectangleShape2D= bounds_shape.shape
	
	if shape is RectangleShape2D:
		var shape_size: Vector2 = shape.size
		var area_position := bounds.global_position
		var shape_position :Vector2= bounds_shape.global_position

		var top_left := area_position + shape_position - (shape_size / 2)
		var bottom_right := area_position + shape_position + (shape_size / 2)
		
		var player_prog = (player.global_position.x-bottom_right.y)/top_left.y
		cam_path.progress = player_prog
