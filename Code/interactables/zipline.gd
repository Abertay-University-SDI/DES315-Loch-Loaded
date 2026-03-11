@tool
extends Node2D

@onready var point_0: Marker2D = $Zipline_0/Zippoint
@export var point_1: Marker2D
@onready var line: Line2D=$Zipline_0/Line2D
@onready var collision_shape: CollisionShape2D=$Zipline_0/StaticBody2D/CollisionShape2D

var dir :Vector2

func _ready() -> void:
	collision_shape.shape = collision_shape.shape.duplicate()

func _process(_delta: float) -> void:
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
