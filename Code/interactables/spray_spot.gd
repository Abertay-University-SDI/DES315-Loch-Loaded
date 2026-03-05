extends Node2D
@export var zone:Area2D
@export var label:Label
var player_in_zone := false
var spray_scene:PackedScene

var last_input_was_controller :bool= false
var painted :bool = false

func get_spray_button_text() -> String:
	var events = InputMap.action_get_events("spray")

	for e in events:
		if last_input_was_controller and e is InputEventJoypadButton:
			return "Right Bumper"
		elif not last_input_was_controller and e is InputEventKey:
			return e.as_text().split(" ")[0]

	return ""

func _input(event):
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		last_input_was_controller = true
	elif event is InputEventKey or event is InputEventMouseButton:
		last_input_was_controller = false


func _on_zone_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = true
		label.text = 'Press "%s" to paint' % get_spray_button_text()
		label.show()

func _on_zone_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = false
		label.hide()



func _ready() -> void:
	spray_scene = ResourceLoader.load("res://Scenes/Interactables/spray.tscn")

func _process(delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("spray"):
		painted = true
		var spray_instance:Node2D= spray_scene.instantiate()
		add_child(spray_instance)
		label.hide()
		zone.monitoring = false

func _get_painted() -> bool:
	return painted
