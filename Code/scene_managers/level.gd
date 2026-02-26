extends Node2D

@onready var pause_menu = $CanvasLayer/PauseScene
@onready var resume_button = $CanvasLayer/PauseScene/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/BackGameButton

func _ready() -> void:
	MenuMusic.stop()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		resume_button.grab_focus()
		pause_menu.show()
		get_tree().paused = true
