@tool
extends Node2D

@onready var point_0: Marker2D = $Zipline_0/Zippoint
@export var point_1: Marker2D
@onready var line: Line2D = $Zipline_0/Line2D
@onready var collision_shape: CollisionShape2D = $Zipline_0/StaticBody2D/CollisionShape2D

var dir: Vector2 = Vector2.RIGHT  # Safe default instead of zero

func _ready() -> void:
	collision_shape.shape = collision_shape.shape.duplicate()

func _process(_delta: float) -> void:
	if !point_0 or !point_1:
		return

	# Update line
	line.clear_points()
	line.add_point(line.to_local(point_0.global_position))
	line.add_point(line.to_local(point_1.global_position))

	# Convert global positions to StaticBody2D local space for the segment shape
	var static_body: StaticBody2D = collision_shape.get_parent()
	collision_shape.shape.a = static_body.to_local(point_0.global_position)
	collision_shape.shape.b = static_body.to_local(point_1.global_position)

	dir = (point_1.global_position - point_0.global_position).normalized()

func get_dir() -> Vector2:
	return dir
