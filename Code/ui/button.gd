extends Button

@export var scene: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	grab_focus()

func _pressed() -> void:
	scene.hide()
	get_tree().get_nodes_in_group("current_ui").back().show()
