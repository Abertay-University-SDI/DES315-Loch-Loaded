@tool
extends Control

@export var action_name: String
@onready var key_label = $TextureRect/Label

func _ready() -> void:
	update_label()

func update_label() -> void:
	if not InputMap.has_action(action_name):
		key_label.text = "none"
		return

	var events = InputMap.action_get_events(action_name)
	if events.size() > 0:
		key_label.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		key_label.text = "Unassigned"
