extends Node2D
@export var zone:Area2D
@export var label:Label
var player_in_zone := false
var spray_scene:PackedScene

func _on_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		label.show()

func _on_zone_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = false
		label.hide()



func _ready() -> void:
	spray_scene = ResourceLoader.load("res://Scenes/spray.tscn")

func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("spray"):
		var spray_instance:Node2D= spray_scene.instantiate()
		add_child(spray_instance)
		label.hide()
		zone.monitoring = false
