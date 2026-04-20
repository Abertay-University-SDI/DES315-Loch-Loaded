extends Node2D
@export var zone:Area2D
@export var label:Label
var player_in_zone := false
var spray_scene:PackedScene
var playerBody:Player

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
		playerBody = body
		label.text = 'Press "%s" to paint' % get_spray_button_text()
		label.show()

func _on_zone_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		player_in_zone = false
		label.hide()



func _ready() -> void:
	spray_scene = ResourceLoader.load("res://Scenes/Spray Spots/spray.tscn")

func _process(_delta: float) -> void:
	if player_in_zone and Input.is_action_just_pressed("spray") and playerBody.UI.getSprayValue() >= 4:
		painted = true
		playerBody.score+=1000
		var spray_instance:Node2D= spray_scene.instantiate()
		add_child(spray_instance)
		label.hide()
		zone.monitoring = false
		playerBody.emit_signal("spray_changed", -4)

func _get_painted() -> bool:
	return painted
