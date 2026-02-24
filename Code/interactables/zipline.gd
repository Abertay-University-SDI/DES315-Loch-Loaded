@tool
extends Node2D

@export var point_0:Marker2D
@export var point_1:Marker2D
@export var line:Line2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	line.global_position = point_0.global_position
	line.clear_points()
	line.add_point(Vector2.ZERO)
	line.add_point(point_1.global_position-point_0.global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
