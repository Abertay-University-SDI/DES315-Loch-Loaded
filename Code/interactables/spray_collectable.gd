extends Node

@export var node: Node2D
@export var area: Area2D

@export var pickUpSound: AudioStreamPlayer2D

var _player: Player = null
var startPos
var targetPos

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player")
	area.body_entered.connect(pickUp)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (node.visible):
		node.global_position.y = move_toward(node.global_position.y, targetPos.y, delta * 10)
		if (abs(targetPos.y - node.global_position.y) < 1):
			if (targetPos.y > startPos.y):
				targetPos = startPos - Vector2(0, 15)
			else:
				targetPos = startPos + Vector2(0, 15)
	pass

func pickUp(body:Node2D) -> void:
	if (body.is_in_group("player") and node.visible):
		_player._addSpray()
		pickUpSound.play()
		node.visible = false
	return

func _on_visibility_changed() -> void:
	startPos = node.global_position
	targetPos = node.global_position - Vector2(0, 15)
