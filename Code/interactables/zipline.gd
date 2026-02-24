@tool
extends Node2D

@export var point_0: Marker2D
@export var point_1: Marker2D
@export var line: Line2D
@export var collision_shape: CollisionShape2D

var dir :Vector2

func _process(delta: float) -> void:
	if !point_0 or !point_1:
		return
	
	# Update line
	line.global_position = point_0.global_position
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(point_1.global_position - point_0.global_position)
	
	collision_shape.global_position = Vector2.ZERO
	collision_shape.shape.a = point_0.global_position
	collision_shape.shape.b = point_1.global_position
	
	dir = -(point_0.global_position-point_1.global_position).normalized()

func get_dir()->Vector2:
	return dir
