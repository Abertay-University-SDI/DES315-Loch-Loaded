extends Control
@onready var settings = $"../SettingsScene"
@onready var pause_ui = $"."
@export var back_button:Button

func _on_back_game_button_pressed() -> void:
	get_tree().paused = false
	hide()


func _on_back_studio_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/studio.tscn")


func _on_settings_button_pressed() -> void:
	pause_ui.hide()
	settings.show()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_back_game_button_visibility_changed() -> void:
	if visible:
		back_button.grab_focus()
