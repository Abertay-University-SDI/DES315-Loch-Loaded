extends Node

@export var thisNode: Node2D
@export var enemyToDie: Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (enemyToDie._get_dead()):
		thisNode.global_position = thisNode.global_position - Vector2(0, -1000)
