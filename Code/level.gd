extends Node2D

@onready var pause_menu = $CanvasLayer/PauseScene

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		pause_menu.show()
		get_tree().paused = true
