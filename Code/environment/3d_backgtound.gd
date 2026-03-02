extends SubViewport

@export var cam_path: PathFollow3D
@export var cam: Camera2D
@export var scene_cam: Camera3D
@export var bounds: Area2D
@export var bounds_shape: CollisionShape2D

func _process(_delta: float) -> void:
	var shape = bounds_shape.shape
	if shape is RectangleShape2D:
		var half_size: Vector2 = shape.size / 2.0
		var center: Vector2 = bounds_shape.global_position

		var top_left     := center - half_size
		var bottom_right := center + half_size

		var range := bottom_right - top_left
		
		var player_prog   = (cam.get_target_position().x - top_left.x) / range.x
		var player_height = (cam.get_target_position().y - top_left.y) / range.y

		scene_cam.global_position.y = 5.0 + player_height * 1.0
		cam_path.progress_ratio = clamp(player_prog, 0.0, 1.0)
