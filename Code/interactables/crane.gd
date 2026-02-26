extends Node2D

@export var point_0: Marker2D

var dir :Vector2

func get_point()->Vector2:
	return point_0.global_position
